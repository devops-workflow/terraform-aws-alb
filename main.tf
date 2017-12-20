#
# Setup AWS LB (ALB/NLB)
#   and S3 for logging, retrieve SSL cert from ACM
#   ?? security groups, dns
#
# AWS provider 1.6 had some breaking changes. This supports 1.6
#
# https://www.terraform.io/docs/providers/aws/r/lb.html
# https://www.terraform.io/docs/providers/aws/r/lb_listener.html
# https://www.terraform.io/docs/providers/aws/r/lb_listener_rule.html
# https://www.terraform.io/docs/providers/aws/r/lb_target_group.html
# https://www.terraform.io/docs/providers/aws/r/lb_target_group_attachment.html
# https://www.terraform.io/docs/providers/aws/d/acm_certificate.html
#
# Only support TCP, HTTP, or HTTPS for now. Not both HTTP and HTTPS in single call?
# TODO Future:
#   Multiple LBs ?

module "enable_logging" {
  source  = "devops-workflow/boolean/local"
  version = "0.1.0"
  value   = "${var.enable_logging}"
}

module "enabled" {
  source  = "devops-workflow/boolean/local"
  version = "0.1.0"
  value   = "${var.enabled}"
}

module "label" {
  source        = "devops-workflow/label/local"
  version       = "0.1.0"
  organization  = "${var.organization}"
  name          = "${var.name}"
  namespace-env = "${var.namespace-env}"
  namespace-org = "${var.namespace-org}"
  environment   = "${var.environment}"
  delimiter     = "${var.delimiter}"
  attributes    = "${var.attributes}"
  tags          = "${var.tags}"
}

/*
# Retrieve SSL certificate if creating SSL LB
Support list for multiple certs ?? First pass, only 1 LB, 1 DNS, 1 cert
SSL Cert lookup
If SSL and given -> var.cert_domain
elif SSL -> "*.${var.env}.${var.domain}"
else count = 0
*/
locals {
  cert_name = "*.${module.label.environment}.${module.label.organization}.com"
}
data "aws_acm_certificate" "this" {
  count   = "${
    module.enabled.value &&
    var.type == "application" &&
    contains(var.lb_protocols, "HTTPS")
    ? 1 : 0}"
  domain  = "${var.certificate_name != "" ? var.certificate_name : local.cert_name }"
}

# TODO: need to separate into 2 resources to support logging, since network doesn't
/*
resource "aws_lb" "application" {
  count               = "${module.enabled.value && var.type == "application" ? 1 : 0}"
  name                = "${module.label.id_32}"
  internal            = "${var.internal}"
  load_balancer_type  = "${var.type}"
  #enable_deletion_protection = "${}"
  idle_timeout        = "${var.idle_timeout}"
  #ip_address_type     = "${}"
  security_groups     = ["${var.security_groups}"]
  subnets             = ["${var.subnets}"]
  tags                = "${module.label.tags}"
  access_logs {
    bucket  = "${var.log_bucket_name}"
    prefix  = "${var.log_location_prefix}"
    enabled = "${module.enable_logging.value}"
  }
  /*
  subnet_mapping {
    subnet_id     = "${}"
    allocation_id = "${}"
  }
  */
  /*
  timeouts {
    create  =
    delete  =
    update  =
  }
  *//*
  depends_on = ["aws_s3_bucket.log_bucket"]
}
/*
resource "aws_lb" "network" {
  count               = "${module.enabled.value && var.type == "network" ? 1 : 0}"
  name                = "${module.label.id_32}"
  internal            = "${var.internal}"
  load_balancer_type  = "${var.type}"
  #enable_deletion_protection = "${}"
  idle_timeout        = "${var.idle_timeout}"
  #ip_address_type     = "${}"
  subnets             = ["${var.subnets}"]
  tags                = "${module.label.tags}"
  /*
  subnet_mapping {
    subnet_id     = "${}"
    allocation_id = "${}"
  }
  */
  /*
  timeouts {
    create  =
    delete  =
    update  =
  }
  *//*
}
*/
resource "aws_lb" "this" {
  count               = "${module.enabled.value}"
  name                = "${module.label.id_32}"
  internal            = "${var.internal}"
  load_balancer_type  = "${var.type}"
  #enable_deletion_protection = "${}"
  idle_timeout        = "${var.idle_timeout}"
  #ip_address_type     = "${}"
  # TODO: not supported for `network`
  #security_groups     = ["${var.security_groups}"]
  subnets             = ["${var.subnets}"]
  tags                = "${module.label.tags}"
  /* Not supported for `network`
  access_logs {
    bucket  = "${var.log_bucket_name}"
    prefix  = "${var.log_location_prefix}"
    enabled = "${module.enable_logging.value}"
  }
  */
  /*
  subnet_mapping {
    subnet_id     = "${}"
    allocation_id = "${}"
  }
  */
  /*
  timeouts {
    create  =
    delete  =
    update  =
  }
  */
  depends_on = ["aws_s3_bucket.log_bucket"]
}

data "aws_iam_policy_document" "bucket_policy" {
  count  = "${
    module.enabled.value &&
    module.enable_logging.value &&
    var.type == "application" &&
    var.create_log_bucket ? 1 : 0}"
  statement {
    sid = "AllowToPutLoadBalancerLogsToS3Bucket"
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "arn:aws:s3:::${var.log_bucket_name}/${var.log_location_prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_elb_service_account.main.id}:root"]
    }
  }
}

resource "aws_s3_bucket" "log_bucket" {
  count         = "${
    module.enabled.value &&
    module.enable_logging.value &&
    var.type == "application &&"
    var.create_log_bucket ? 1 : 0}"
  bucket        = "${var.log_bucket_name}"
  #acl
  policy        = "${var.bucket_policy == "" ? data.aws_iam_policy_document.bucket_policy.json : var.bucket_policy}"
  force_destroy = "${var.force_destroy_log_bucket}"
  tags          = "${merge(var.tags, map("Name", format("%s", var.log_bucket_name)))}"
  #tags            = "${module.label.tags}"
  lifecycle_rule {
    id = "log-expiration"
    enabled = "true"
    expiration {
      days = "7" # Change to var
    }
    #tags  = "${module.label.tags}"
  }
}

locals {
  // Set default to any port set that has not been specified
  instance_http_ports   = "${length(compact(split(",", var.instance_http_ports))) > 0 ? var.instance_http_ports : var.ports}"
  instance_https_ports  = "${length(compact(split(",", var.instance_https_ports))) > 0 ? var.instance_https_ports : var.ports}"
  instance_tcp_ports    = "${length(compact(split(",", var.instance_tcp_ports))) > 0 ? var.instance_tcp_ports : var.ports}"
  lb_http_ports         = "${length(compact(split(",", var.lb_http_ports))) > 0 ? var.lb_http_ports : var.ports}"
  lb_https_ports        = "${length(compact(split(",", var.lb_https_ports))) > 0 ? var.lb_https_ports : var.ports}"
  lb_tcp_ports          = "${length(compact(split(",", var.lb_tcp_ports))) > 0 ? var.lb_tcp_ports : var.ports}"
}
/* Debugging
output "ports" { value = "${var.ports}" }
output "instance_http_ports" { value = "${local.instance_http_ports}" }
output "instance_https_ports" { value = "${local.instance_https_ports}" }
output "instance_tcp_ports" { value = "${local.instance_tcp_ports}" }
output "lb_http_ports" { value = "${local.lb_http_ports}" }
output "lb_https_ports" { value = "${local.lb_https_ports}" }
output "lb_tcp_ports" { value = "${local.lb_tcp_ports}" }
*/
/*
locals {
  backend_protocol = "${var.type == "network" ? "TCP" : upper(var.backend_protocol)}"
  #all_ports = "${concat(split(",", var.port), var.additional_ports)}"
  #all_app_ports = "${concat(var.http_instance_ports, var.https_instance_ports)}"
}
*/
# TODO: Support creating multiple
#   change to 1 resource with list of maps (port, proto?) to create
resource "aws_lb_target_group" "application-http" {
  count    = "${
    module.enabled.value &&
    var.type == "application" &&
    contains(var.lb_protocols, "HTTP")
    ? length(compact(split(",", local.instance_http_ports))) : 0}"
  name     = "${join("-",
    list(substr(module.label.id_org,0,26 <= length(module.label.id_org) ? 26 : length(module.label.id_org))),
    list(element(compact(split(",",local.instance_http_ports)), count.index))
    )}"
  port     = "${element(compact(split(",",local.instance_http_ports)), count.index)}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  #deregistration_delay  = "${}"
  #target_type           = "${}"
  health_check {
    interval            = "${var.health_check_interval}"
    path                = "${var.health_check_path}"
    port                = "${var.health_check_port}"
    healthy_threshold   = "${var.health_check_healthy_threshold}"
    unhealthy_threshold = "${var.health_check_unhealthy_threshold}"
    timeout             = "${var.health_check_timeout}"
    protocol            = "${var.health_check_protocol}"
    matcher             = "${var.health_check_matcher}"
  }
  # ALB only. Cannot be defined for network LB
  stickiness {
    type            = "lb_cookie"
    cookie_duration = "${var.cookie_duration > 0 ? var.cookie_duration : 1}"
    enabled         = "${var.cookie_duration > 0 ? true : false}"
  }
  tags     = "${module.label.tags}"
}
resource "aws_lb_target_group" "application-https" {
  count    = "${
    module.enabled.value &&
    var.type == "application" &&
    contains(var.lb_protocols, "HTTPS")
    ? length(compact(split(",", local.instance_https_ports))) : 0}"  # "${length(local.all_ports)}"
  name     = "${join("-",
    list(substr(module.label.id_org,0,26 <= length(module.label.id_org) ? 26 : length(module.label.id_org))),
    list(element(compact(split(",",local.instance_https_ports)), count.index))
    )}"
  port     = "${element(compact(split(",",local.instance_https_ports)), count.index)}"
  protocol = "HTTP"
  # count.index <= length(var.http_instance_ports) ? "HTTP" : "HTTPS"
  vpc_id   = "${var.vpc_id}"
  #deregistration_delay  = "${}"
  #target_type           = "${}"
  health_check {
    interval            = "${var.health_check_interval}"
    path                = "${var.health_check_path}"
    port                = "${var.health_check_port}"
    healthy_threshold   = "${var.health_check_healthy_threshold}"
    unhealthy_threshold = "${var.health_check_unhealthy_threshold}"
    timeout             = "${var.health_check_timeout}"
    protocol            = "${var.health_check_protocol}"
    matcher             = "${var.health_check_matcher}"
  }
  # ALB only. Cannot be defined for network LB
  stickiness {
    type            = "lb_cookie"
    cookie_duration = "${var.cookie_duration > 0 ? var.cookie_duration : 1}"
    enabled         = "${var.cookie_duration > 0 ? true : false}"
  }
  tags     = "${module.label.tags}"
}
resource "aws_lb_target_group" "network" {
  count    = "${
    module.enabled.value &&
    var.type == "network"
    ? length(compact(split(",", local.instance_tcp_ports))) : 0}"
  name     = "${join("-",
    list(substr(module.label.id_org,0,26 <= length(module.label.id_org) ? 26 : length(module.label.id_org))),
    list(element(compact(split(",",local.instance_tcp_ports)), count.index))
    )}"
  port     = "${element(compact(split(",",local.instance_tcp_ports)), count.index)}"
  protocol = "TCP"
  vpc_id   = "${var.vpc_id}"
  #deregistration_delay  = "${}"
  #target_type           = "${}"
  health_check {
    interval            = "${var.health_check_interval}"
    port                = "${var.health_check_port}"
    healthy_threshold   = "${var.health_check_healthy_threshold}"
    unhealthy_threshold = "${var.health_check_unhealthy_threshold}"
    protocol            = "${var.health_check_protocol}"
  }
  tags     = "${module.label.tags}"
}

# TODO: change to 1 resource with list of maps (port, proto?, target group, ssl) to create
#   lookup ssl cert arn from ACM
#   use lb_listener_rule for additional ports
#   Up to 3 listener types (TCP or (HTTP/HTTPS))
resource "aws_lb_listener" "http" {
  count             = "${
    module.enabled.value &&
    var.type == "application" &&
    contains(var.lb_protocols, "HTTP")
    ? length(compact(split(",", local.lb_http_ports))) : 0}"
  load_balancer_arn = "${aws_lb.this.arn}"
  port              = "${element(compact(split(",",local.lb_http_ports)), count.index)}"
  protocol          = "HTTP"
  default_action {
    #target_group_arn = "${aws_lb_target_group.target_group.id}"
    target_group_arn = "${element(concat(aws_lb_target_group.application-http.*.arn), count.index)}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "https" {
  count             = "${
    module.enabled.value &&
    var.type == "application" &&
    contains(var.lb_protocols, "HTTPS")
    ? length(compact(split(",", local.lb_https_ports))) : 0}"
  load_balancer_arn = "${aws_lb.this.arn}"
  port              = "${element(compact(split(",",local.lb_https_ports)), count.index)}"
  protocol          = "HTTPS"
  certificate_arn   = "${element(concat(data.aws_acm_certificate.this.*.arn, list("")), 0)}"
  ssl_policy        = "${var.security_policy}"
  default_action {
    #target_group_arn = "${aws_lb_target_group.target_group.id}"
    target_group_arn = "${element(concat(aws_lb_target_group.application-https.*.arn), count.index)}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "network" {
  count             = "${
    module.enabled.value &&
    var.type == "network"
    ? length(compact(split(",", local.lb_tcp_ports))) : 0}"
  load_balancer_arn = "${aws_lb.this.arn}"
  port              = "${element(compact(split(",",local.lb_tcp_ports)), count.index)}"
  protocol          = "TCP"
  default_action {
    target_group_arn = "${element(concat(aws_lb_target_group.network.*.arn), count.index)}"
    type             = "forward"
  }
}

/*
resource "aws_lb_listener_rule" "this" {
  count
  listener_arn
  priority
  action {
    target_group_arn
    type
  }
  condition {
    field
    values
  }
}
*/
