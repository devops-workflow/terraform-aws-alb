//
// LB attributes
//
output "arn" {
  description = "ARN of the LB itself. Useful for debug output, for example when attaching a WAF."
  value       = "${module.lb-https.arn}"
}

output "dns_name" {
  description = "The DNS name of the LB presumably to be used with a friendlier CNAME."
  value       = "${module.lb-https.dns_name}"
}

output "id" {
  description = "The ID of the LB we created."
  value       = "${module.lb-https.id}"
}

output "zone_id" {
  description = "The zone_id of the LB to assist with creating DNS records."
  value       = "${module.lb-https.zone_id}"
}

# arn_suffix
# canonical_hosted_zone_id

//
// LB Listener attributes
//
output "listener_http_arns" {
  description = "The ARNs of the HTTP LB Listeners"
  value       = "${module.lb-https.listener_http_arns}"
}

output "listener_http_ids" {
  description = "The IDs of the HTTP LB Listeners"
  value       = "${module.lb-https.listener_http_ids}"
}

output "listener_https_arns" {
  description = "The ARNs of the HTTPS LB Listeners"
  value       = "${module.lb-https.listener_https_arns}"
}

output "listener_https_ids" {
  description = "The IDs of the HTTPS LB Listeners"
  value       = "${module.lb-https.listener_https_ids}"
}

output "listener_tcp_arns" {
  description = "The ARNs of the network TCP LB Listeners"
  value       = "${module.lb-https.listener_tcp_arns}"
}

output "listener_tcp_ids" {
  description = "The IDs of the network TCP LB Listeners"
  value       = "${module.lb-https.listener_tcp_ids}"
}

output "listener_arns" {
  description = "ARNs of all the LB Listeners"
  value       = "${module.lb-https.listener_arns}"
}

output "listener_ids" {
  description = "IDs of all the LB Listeners"
  value       = "${module.lb-https.listener_ids}"
}

//
// LB Target Group attributes
//
output "target_group_http_arns" {
  description = "ARNs of the HTTP target groups. Useful for passing to your Auto Scaling group module."
  value       = "${module.lb-https.target_group_http_arns}"
}

output "target_group_https_arns" {
  description = "ARNs of the HTTPS target groups. Useful for passing to your Auto Scaling group module."
  value       = "${module.lb-https.target_group_https_arns}"
}

output "target_group_tcp_arns" {
  description = "ARNs of the TCP target groups. Useful for passing to your Auto Scaling group module."
  value       = "${module.lb-https.target_group_tcp_arns}"
}

output "target_group_arns" {
  description = "ARNs of all the target groups. Useful for passing to your Auto Scaling group module."
  value       = "${module.lb-https.target_group_arns}"
}

output "target_group_http_ids" {
  description = "IDs of the HTTP target groups"
  value       = "${module.lb-https.target_group_http_ids}"
}

output "target_group_https_ids" {
  description = "IDs of the HTTPS target groups"
  value       = "${module.lb-https.target_group_https_ids}"
}

output "target_group_tcp_ids" {
  description = "IDs of the TCP target groups"
  value       = "${module.lb-https.target_group_tcp_ids}"
}

output "target_group_ids" {
  description = "IDs of all the target groups"
  value       = "${module.lb-https.target_group_ids}"
}

# arn_suffix
# name

//
// Misc
//
output "principal_account_id" {
  description = "The AWS-owned account given permissions to write your LB logs to S3."
  value       = "${module.lb-https.principal_account_id}"
}
