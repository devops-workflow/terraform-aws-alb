#
# Setup AWS LB (ALB/NLB)
#   and S3 for logging, retrieve SSL cert from ACM
#   ?? security groups, dns
#
# AWS provider 1.6 has bugs that prevent NLBs management. Issue #2708
# Currently supporting 1.5.0
#
# https://www.terraform.io/docs/providers/aws/r/lb.html
# https://www.terraform.io/docs/providers/aws/r/lb_listener.html
# https://www.terraform.io/docs/providers/aws/r/lb_listener_rule.html
# https://www.terraform.io/docs/providers/aws/r/lb_target_group.html
# https://www.terraform.io/docs/providers/aws/r/lb_target_group_attachment.html
# https://www.terraform.io/docs/providers/aws/d/acm_certificate.html
#
# TODO Future:
#   Multiple LBs ?

module "enable_logging" {
  #source  = "devops-workflow/boolean/local"
  #version = "0.1.1"
  source  = "git::https://github.com/WisePricer/terraform-local-boolean.git"
  value   = "${var.enable_logging}"
}

module "enabled" {
  #source  = "devops-workflow/boolean/local"
  #version = "0.1.1"
  source  = "git::https://github.com/WisePricer/terraform-local-boolean.git"
  value   = "${var.enabled}"
}

module "label" {
  #source        = "devops-workflow/label/local"
  #version       = "0.1.3"
  source        = "git::https://github.com/WisePricer/terraform-local-label.git"
  organization  = "${var.organization}"
  name          = "${var.name}"
  namespace-env = "${var.namespace-env}"
  namespace-org = "${var.namespace-org}"
  environment   = "${var.environment}"
  delimiter     = "${var.delimiter}"
  attributes    = "${var.attributes}"
  tags          = "${var.tags}"
}

# TODO: need to support from var both basename and a complete name
#       may have 1 log bucket for many apps
module "log_bucket" {
  #source        = "devops-workflow/label/local"
  #version       = "0.1.3"
  source        = "git::https://github.com/WisePricer/terraform-local-label.git"
  organization  = "${var.organization}"
  name          = "${var.log_bucket_name}"
  namespace-env = true
  namespace-org = true
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
  count = "${
    module.enabled.value &&
    var.type == "application" &&
    contains(var.lb_protocols, "HTTPS")
    ? 1 : 0}"

  domain = "${var.certificate_name != "" ? var.certificate_name : local.cert_name }"

  #statuses = ["ISSUED"]
}

data "aws_acm_certificate" "additional" {
  count = "${
    module.enabled.value &&
    var.type == "application" &&
    contains(var.lb_protocols, "HTTPS")
    ? length(var.certificate_additional_names) : 0
  }"

  domain = "${var.certificate_additional_names[count.index]}"
}

# May need to create 2: 1 w/ logs and 1 w/o logs
resource "aws_lb" "application" {
  count              = "${module.enabled.value && var.type == "application" ? 1 : 0}"
  name               = "${module.label.id_32}"
  internal           = "${var.internal}"
  load_balancer_type = "${var.type}"

  enable_deletion_protection = "${var.enable_deletion_protection}"
  enable_http2               = "${var.enable_http2}"
  idle_timeout               = "${var.idle_timeout}"
  security_groups            = ["${var.security_groups}"]
  subnets                    = ["${var.subnets}"]
  tags                       = "${module.label.tags}"

  #ip_address_type     = "${}"

  # Doesn't seem to be able to disable properly
  #  access_logs {
  #    bucket  = "${module.log_bucket.id}"  # ? Cannot be empty and must exist
  #    prefix  = "${var.log_location_prefix}"
  #    enabled = "${module.enable_logging.value}"
  #  }
  #  subnet_mapping {
  #    subnet_id     = "${}"
  #    allocation_id = "${}"
  #  }
  #  timeouts {
  #    create  =
  #    delete  =
  #    update  =
  #  }
  depends_on = ["aws_s3_bucket.log_bucket"]
}

resource "aws_lb" "network" {
  count              = "${module.enabled.value && var.type == "network" ? 1 : 0}"
  name               = "${module.label.id_32}"
  internal           = "${var.internal}"
  load_balancer_type = "${var.type}"

  enable_cross_zone_load_balancing = "${var.enable_cross_zone_load_balancing}"
  enable_deletion_protection       = "${var.enable_deletion_protection}"
  idle_timeout                     = "${var.idle_timeout}"
  subnets                          = ["${var.subnets}"]
  tags                             = "${module.label.tags}"

  #ip_address_type     = "${}"

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
}

data "aws_iam_policy_document" "bucket_policy" {
  count = "${
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
      "arn:aws:s3:::${module.log_bucket.id}/${var.log_location_prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_elb_service_account.main.id}:root"]
    }
  }
}

resource "aws_s3_bucket" "log_bucket" {
  count = "${
    module.enabled.value &&
    module.enable_logging.value &&
    var.type == "application" &&
    var.create_log_bucket ? 1 : 0}"

  bucket = "${module.log_bucket.id}"

  #acl
  policy        = "${var.bucket_policy == "" ? data.aws_iam_policy_document.bucket_policy.json : var.bucket_policy}"
  force_destroy = "${var.force_destroy_log_bucket}"
  tags          = "${merge(var.tags, map("Name", format("%s", var.log_bucket_name)))}"

  #tags            = "${module.label.tags}"
  lifecycle_rule {
    id      = "log-expiration"
    enabled = "true"

    expiration {
      days = "7" # Change to var
    }

    #tags  = "${module.label.tags}"
  }
}

locals {
  // Set default to any port set that has not been specified
  instance_http_ports  = "${length(compact(split(",", var.instance_http_ports))) > 0 ? var.instance_http_ports : var.ports}"
  instance_https_ports = "${length(compact(split(",", var.instance_https_ports))) > 0 ? var.instance_https_ports : var.ports}"
  instance_tcp_ports   = "${length(compact(split(",", var.instance_tcp_ports))) > 0 ? var.instance_tcp_ports : var.ports}"
  lb_http_ports        = "${length(compact(split(",", var.lb_http_ports))) > 0 ? var.lb_http_ports : var.ports}"
  lb_https_ports       = "${length(compact(split(",", var.lb_https_ports))) > 0 ? var.lb_https_ports : var.ports}"
  lb_tcp_ports         = "${length(compact(split(",", var.lb_tcp_ports))) > 0 ? var.lb_tcp_ports : var.ports}"
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

resource "aws_lb_target_group" "application-http" {
  count = "${
    module.enabled.value &&
    var.type == "application" &&
    contains(var.lb_protocols, "HTTP")
    ? length(compact(split(",", local.instance_http_ports))) : 0}"

  name = "${join("-",
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

  tags = "${module.label.tags}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "application-https" {
  count = "${
    module.enabled.value &&
    var.type == "application" &&
    contains(var.lb_protocols, "HTTPS")
    ? length(compact(split(",", local.instance_https_ports))) : 0}"

  name = "${join("-",
    list(substr(module.label.id_org,0,26 <= length(module.label.id_org) ? 26 : length(module.label.id_org))),
    list(element(compact(split(",",local.instance_https_ports)), count.index))
    )}"

  port     = "${element(compact(split(",",local.instance_https_ports)), count.index)}"
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

  tags = "${module.label.tags}"

  lifecycle {
    create_before_destroy = true
  }
}

# Build NLB Target Group health check stansa
locals {
  health_base = {
    interval            = "10"
    port                = "${var.health_check_port}"
    healthy_threshold   = "${var.health_check_healthy_threshold}"
    unhealthy_threshold = "${var.health_check_unhealthy_threshold}"
    protocol            = "${var.health_check_protocol}"
  }

  http = {
    path    = "${var.health_check_path}"
    matcher = "200-399"
    timeout = "6"
  }

  h_keys      = "${join(",", keys(local.health_base))}"
  h_vals      = "${join(",", values(local.health_base))}"
  http_keys   = "${join(",", keys(local.http))}"
  http_vals   = "${join(",", values(local.http))}"
  keys        = "${ var.health_check_protocol == "TCP" ? local.h_keys : "${local.h_keys},${local.http_keys}" }"
  vals        = "${ var.health_check_protocol == "TCP" ? local.h_vals : "${local.h_vals},${local.http_vals}" }"
  healthcheck = "${zipmap(split(",", local.keys), split(",", local.vals))}"
}

resource "aws_lb_target_group" "network" {
  count = "${
    module.enabled.value &&
    var.type == "network"
    ? length(compact(split(",", local.instance_tcp_ports))) : 0}"

  name = "${join("-",
    list(substr(module.label.id_org,0,26 <= length(module.label.id_org) ? 26 : length(module.label.id_org))),
    list(element(compact(split(",",local.instance_tcp_ports)), count.index))
    )}"

  health_check = "${list(local.healthcheck)}"
  port         = "${element(compact(split(",",local.instance_tcp_ports)), count.index)}"
  protocol     = "TCP"
  stickiness   = []
  tags         = "${module.label.tags}"
  vpc_id       = "${var.vpc_id}"

  #deregistration_delay  = "${}"
  #target_type           = "${}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "http" {
  count = "${
    module.enabled.value &&
    var.type == "application" &&
    contains(var.lb_protocols, "HTTP")
    ? length(compact(split(",", local.lb_http_ports))) : 0}"

  load_balancer_arn = "${element(concat(aws_lb.application.*.arn, aws_lb.network.*.arn, list("")), 0)}"
  port              = "${element(compact(split(",",local.lb_http_ports)), count.index)}"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${element(concat(aws_lb_target_group.application-http.*.arn), count.index)}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "https" {
  count = "${
    module.enabled.value &&
    var.type == "application" &&
    contains(var.lb_protocols, "HTTPS")
    ? length(compact(split(",", local.lb_https_ports))) : 0}"

  load_balancer_arn = "${element(concat(aws_lb.application.*.arn, aws_lb.network.*.arn, list("")), 0)}"
  port              = "${element(compact(split(",",local.lb_https_ports)), count.index)}"
  protocol          = "HTTPS"
  certificate_arn   = "${element(concat(data.aws_acm_certificate.this.*.arn, list("")), 0)}"
  ssl_policy        = "${var.security_policy}"

  default_action {
    target_group_arn = "${element(concat(aws_lb_target_group.application-https.*.arn), count.index)}"
    type             = "forward"
  }
}

# Additional certs for https listener on first port
# TODO: figure out way to add to all ports
#   temp: could add another stansa for second port if >= 2 https ports
resource "aws_lb_listener_certificate" "https" {
  count = "${
    module.enabled.value &&
    var.type == "application" &&
    contains(var.lb_protocols, "HTTPS")
    ? length(var.certificate_additional_names) : 0 }"

  listener_arn    = "${element(aws_lb_listener.https.*.arn, 0)}"
  certificate_arn = "${element(data.aws_acm_certificate.additional.*.arn, count.index)}"
}

resource "aws_lb_listener" "network" {
  count = "${
    module.enabled.value &&
    var.type == "network"
    ? length(compact(split(",", local.lb_tcp_ports))) : 0}"

  load_balancer_arn = "${element(concat(aws_lb.application.*.arn, aws_lb.network.*.arn, list("")), 0)}"
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
