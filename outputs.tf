//
// LB attributes
//
output "arn" {
  description = "ARN of the LB itself. Useful for debug output, for example when attaching a WAF."
  value       = "${element(concat(aws_lb.this.*.arn, list("")), 0)}"
}
output "dns_name" {
  description = "The DNS name of the LB presumably to be used with a friendlier CNAME."
  value       = "${element(concat(aws_lb.this.*.dns_name, list("")), 0)}"
}
output "id" {
  description = "The ID of the LB we created."
  value       = "${element(concat(aws_lb.this.*.id, list("")), 0)}"
}
output "zone_id" {
  description = "The zone_id of the LB to assist with creating DNS records."
  value       = "${element(concat(aws_lb.this.*.zone_id, list("")), 0)}"
}
# arn_suffix
# canonical_hosted_zone_id

//
// LB Listener attributes
//
output "listener_http_arn" {
  description = "The ARN of the HTTP LB Listener we created."
  value       = "${element(concat(aws_lb_listener.http.*.arn, list("")), 0)}"
}
output "listener_http_id" {
  description = "The ID of the HTTP LB Listener we created."
  value       = "${element(concat(aws_lb_listener.http.*.id, list("")), 0)}"
}
output "listener_https_arn" {
  description = "The ARN of the HTTPS LB Listener we created."
  value       = "${element(concat(aws_lb_listener.https.*.arn, list("")), 0)}"
}
output "listener_https_id" {
  description = "The ID of the HTTPS LB Listener we created."
  value       = "${element(concat(aws_lb_listener.https.*.id, list("")), 0)}"
}
output "listener_tcp_arn" {
  description = "The ARN of the network TCP LB Listener we created."
  value       = "${element(concat(aws_lb_listener.network.*.arn, list("")), 0)}"
}
output "listener_tcp_id" {
  description = "The ID of the network TCP LB Listener we created."
  value       = "${element(concat(aws_lb_listener.network.*.id, list("")), 0)}"
}

//
// LB Target Group attributes
//
/*
output "target_group_arn" {
  description = "ARN of the target group. Useful for passing to your Auto Scaling group module."
  value       = "${element(concat(aws_lb_target_group.application.*.arn, aws_lb_target_group.network.*.arn, list("")), 0)}"
}
*/
# id
# arn_suffix
# name

//
// Misc
//
output "principal_account_id" {
  description = "The AWS-owned account given permissions to write your LB logs to S3."
  value       = "${data.aws_elb_service_account.main.id}"
}
