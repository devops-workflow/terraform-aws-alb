#
# Setup AWS LB (ALB/NLB)
#   and S3 for logging, retrieve SSL cert from ACM
#   ?? security groups, dns
#
# https://www.terraform.io/docs/providers/aws/r/lb.html
# https://www.terraform.io/docs/providers/aws/r/lb_listener.html
# https://www.terraform.io/docs/providers/aws/r/lb_listener_rule.html
# https://www.terraform.io/docs/providers/aws/r/lb_target_group.html
# https://www.terraform.io/docs/providers/aws/r/lb_target_group_attachment.html
# https://www.terraform.io/docs/providers/aws/d/acm_certificate.html

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
SSL Cert lookup
If SSL and given -> var.cert_domain
elif SSL -> "*.${var.env}.${var.domain}"
else count = 0

data "aws_acm_certificate" "this" {
  count   = "${module.enabled.value}"
  domain  = "tf.example.com"
}
*/

resource "aws_lb" "main" {
  count               = "${module.enabled.value}"
  name                = "${var.lb_name}"
  internal            = "${var.lb_is_internal}"
  #load_balancer_type  =
  #idle_timeout        =
  security_groups     = ["${var.lb_security_groups}"]
  subnets             = ["${var.subnets}"]
  tags                = "${merge(var.tags, map("Name", format("%s", var.lb_name)))}"
  #tags                = "${module.label.tags}"
  access_logs {
    bucket  = "${var.log_bucket_name}"
    prefix  = "${var.log_location_prefix}"
    enabled = "${var.enable_logging}"
  }
  depends_on = ["aws_s3_bucket.log_bucket"]
}

data "aws_iam_policy_document" "bucket_policy" {
  count  = "${module.enabled.value}"
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
  count         = "${module.enabled.value ? (var.create_log_bucket ? 1 : 0) : 0}"
  bucket        = "${var.log_bucket_name}"
  policy        = "${var.bucket_policy == "" ? data.aws_iam_policy_document.bucket_policy.json : var.bucket_policy}"
  force_destroy = "${var.force_destroy_log_bucket}"
  tags          = "${merge(var.tags, map("Name", format("%s", var.log_bucket_name)))}"
  #tags            = "${module.label.tags}"
}

# TODO: Support creating multiple
#   change to 1 resource with list of maps (port, proto?) to create
resource "aws_lb_target_group" "target_group" {
  count    = "${module.enabled.value}"
  name     = "${var.lb_name}-tg"
  port     = "${var.backend_port}"
  protocol = "${upper(var.backend_protocol)}"
  vpc_id   = "${var.vpc_id}"
  #deregistration_delay  =
  health_check {
    interval            = "${var.health_check_interval}"
    path                = "${var.health_check_path}"
    port                = "${var.health_check_port}"
    healthy_threshold   = "${var.health_check_healthy_threshold}"
    unhealthy_threshold = "${var.health_check_unhealthy_threshold}"
    timeout             = "${var.health_check_timeout}"
    protocol            = "${var.backend_protocol}"
    matcher             = "${var.health_check_matcher}"
  }
  # TODO: Make optional
  stickiness {
    type            = "lb_cookie"
    cookie_duration = "${var.cookie_duration}"
    enabled         = "${ var.cookie_duration == 1 ? false : true}"
  }
  tags = "${merge(var.tags, map("Name", format("%s-tg", var.lb_name)))}"
  #tags            = "${module.label.tags}"
}

# TODO: change to 1 resource with list of maps (port, proto?, target group, ssl) to create
#   lookup ssl cert arn from ACM
resource "aws_lb_listener" "frontend_http" {
  count             = "${module.enabled.value ? (contains(var.lb_protocols, "HTTP") ? 1 : 0) : 0}"
  load_balancer_arn = "${aws_lb.main.arn}"
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = "${aws_lb_target_group.target_group.id}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "frontend_https" {
  count             = "${module.enabled.value ? (contains(var.lb_protocols, "HTTPS") ? 1 : 0) : 0}"
  load_balancer_arn = "${aws_lb.main.arn}"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "${var.certificate_arn}"
  ssl_policy        = "${var.security_policy}"
  default_action {
    target_group_arn = "${aws_lb_target_group.target_group.id}"
    type             = "forward"
  }
}
