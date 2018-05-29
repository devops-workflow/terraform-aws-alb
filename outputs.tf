//
// LB attributes
//
output "arn" {
  description = "ARN of the LB itself. Useful for debug output, for example when attaching a WAF."
  value       = "${element(concat(aws_lb.application.*.arn, aws_lb.network.*.arn, list("")), 0)}"
}

output "arn_suffix" {
  description = "ARN suffix of the LB itself. Useful for debug output, for example when attaching a WAF."
  value       = "${element(concat(aws_lb.application.*.arn_suffix, aws_lb.network.*.arn_suffix, list("")), 0)}"
}

output "dns_name" {
  description = "The DNS name of the LB presumably to be used with a friendlier CNAME."
  value       = "${element(concat(aws_lb.application.*.dns_name, aws_lb.network.*.dns_name, list("")), 0)}"
}

output "id" {
  description = "The ID of the LB we created."
  value       = "${element(concat(aws_lb.application.*.id, aws_lb.network.*.id, list("")), 0)}"
}

output "zone_id" {
  description = "The zone_id of the LB to assist with creating DNS records."
  value       = "${element(concat(aws_lb.application.*.zone_id, aws_lb.network.*.zone_id, list("")), 0)}"
}

# arn_suffix
# canonical_hosted_zone_id

//
// LB Listener attributes
//
output "listener_http_arns" {
  description = "The ARNs of the HTTP LB Listeners"
  value       = "${aws_lb_listener.http.*.arn}"
}

output "listener_http_ids" {
  description = "The IDs of the HTTP LB Listeners"
  value       = "${aws_lb_listener.http.*.id}"
}

output "listener_https_arns" {
  description = "The ARNs of the HTTPS LB Listeners"
  value       = "${aws_lb_listener.https.*.arn}"
}

output "listener_https_ids" {
  description = "The IDs of the HTTPS LB Listeners"
  value       = "${aws_lb_listener.https.*.id}"
}

output "listener_tcp_arns" {
  description = "The ARNs of the network TCP LB Listeners"
  value       = "${aws_lb_listener.network.*.arn}"
}

output "listener_tcp_ids" {
  description = "The IDs of the network TCP LB Listeners"
  value       = "${aws_lb_listener.network.*.id}"
}

output "listener_arns" {
  description = "ARNs of all the LB Listeners"
  value       = "${compact(concat(aws_lb_listener.http.*.arn,aws_lb_listener.https.*.arn,aws_lb_listener.network.*.arn))}"
}

output "listener_ids" {
  description = "IDs of all the LB Listeners"
  value       = "${compact(concat(aws_lb_listener.http.*.id,aws_lb_listener.https.*.id,aws_lb_listener.network.*.id))}"
}

//
// LB Target Group attributes
//
output "target_group_http_arns" {
  description = "ARNs of the HTTP target groups. Useful for passing to your Auto Scaling group module."
  value       = "${aws_lb_target_group.application-http.*.arn}"
}

output "target_group_https_arns" {
  description = "ARNs of the HTTPS target groups. Useful for passing to your Auto Scaling group module."
  value       = "${aws_lb_target_group.application-https.*.arn}"
}

output "target_group_tcp_arns" {
  description = "ARNs of the TCP target groups. Useful for passing to your Auto Scaling group module."
  value       = "${aws_lb_target_group.network.*.arn}"
}

output "target_group_arns" {
  description = "ARNs of all the target groups. Useful for passing to your Auto Scaling group module."
  value       = "${compact(concat(aws_lb_target_group.application-http.*.arn,aws_lb_target_group.application-https.*.arn,aws_lb_target_group.network.*.arn))}"
}

output "target_group_arns_suffix" {
  description = "ARNs suffix of all the target groups. Useful for passing to your Auto Scaling group module."
  value       = "${compact(concat(aws_lb_target_group.application-http.*.arn_suffix,aws_lb_target_group.application-https.*.arn_suffix,aws_lb_target_group.network.*.arn_suffix))}"
}

output "target_group_http_ids" {
  description = "IDs of the HTTP target groups"
  value       = "${aws_lb_target_group.application-http.*.id}"
}

output "target_group_https_ids" {
  description = "IDs of the HTTPS target groups"
  value       = "${aws_lb_target_group.application-https.*.id}"
}

output "target_group_tcp_ids" {
  description = "IDs of the TCP target groups"
  value       = "${aws_lb_target_group.network.*.id}"
}

output "target_group_ids" {
  description = "IDs of all the target groups"
  value       = "${compact(concat(aws_lb_target_group.application-http.*.id,aws_lb_target_group.application-https.*.id,aws_lb_target_group.network.*.id))}"
}

# arn_suffix
# name

//
// Misc
//
output "principal_account_id" {
  description = "The AWS-owned account given permissions to write your LB logs to S3."
  value       = "${data.aws_elb_service_account.main.id}"
}
