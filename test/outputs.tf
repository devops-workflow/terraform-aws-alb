/*
output "ports" { value = "${module.lb.ports}" }
output "instance_http_ports" { value = "${module.lb.instance_http_ports}" }
output "instance_https_ports" { value = "${module.lb.instance_https_ports}" }
output "instance_tcp_ports" { value = "${module.lb.instance_tcp_ports}" }
output "lb_http_ports" { value = "${module.lb.lb_http_ports}" }
output "lb_https_ports" { value = "${module.lb.lb_https_ports}" }
output "lb_tcp_ports" { value = "${module.lb.lb_tcp_ports}" }
*/
//
// LB attributes
//
output "tcp_arn" {
  description = "ARN of the LB itself. Useful for debug output, for example when attaching a WAF."
  value       = "${module.lb-tcp.arn}"
}

output "tcp_dns_name" {
  description = "The DNS name of the LB presumably to be used with a friendlier CNAME."
  value       = "${module.lb-tcp.dns_name}"
}

output "tcp_id" {
  description = "The ID of the LB we created."
  value       = "${module.lb-tcp.id}"
}

output "tcp_zone_id" {
  description = "The zone_id of the LB to assist with creating DNS records."
  value       = "${module.lb-tcp.zone_id}"
}

# arn_suffix
# canonical_hosted_zone_id

//
// LB Listener attributes
//
output "tcp_listener_http_arns" {
  description = "The ARNs of the HTTP LB Listeners"
  value       = "${module.lb-tcp.listener_http_arns}"
}

output "tcp_listener_http_ids" {
  description = "The IDs of the HTTP LB Listeners"
  value       = "${module.lb-tcp.listener_http_ids}"
}

output "tcp_listener_https_arns" {
  description = "The ARNs of the HTTPS LB Listeners"
  value       = "${module.lb-tcp.listener_https_arns}"
}

output "tcp_listener_https_ids" {
  description = "The IDs of the HTTPS LB Listeners"
  value       = "${module.lb-tcp.listener_https_ids}"
}

output "tcp_listener_tcp_arns" {
  description = "The ARNs of the network TCP LB Listeners"
  value       = "${module.lb-tcp.listener_tcp_arns}"
}

output "tcp_listener_tcp_ids" {
  description = "The IDs of the network TCP LB Listeners"
  value       = "${module.lb-tcp.listener_tcp_ids}"
}

output "tcp_listener_arns" {
  description = "ARNs of all the LB Listeners"
  value       = "${module.lb-tcp.listener_arns}"
}

output "tcp_listener_ids" {
  description = "IDs of all the LB Listeners"
  value       = "${module.lb-tcp.listener_ids}"
}

//
// LB Target Group attributes
//
output "tcp_target_group_http_arns" {
  description = "ARNs of the HTTP target groups. Useful for passing to your Auto Scaling group module."
  value       = "${module.lb-tcp.target_group_http_arns}"
}

output "tcp_target_group_https_arns" {
  description = "ARNs of the HTTPS target groups. Useful for passing to your Auto Scaling group module."
  value       = "${module.lb-tcp.target_group_https_arns}"
}

output "tcp_target_group_tcp_arns" {
  description = "ARNs of the TCP target groups. Useful for passing to your Auto Scaling group module."
  value       = "${module.lb-tcp.target_group_tcp_arns}"
}

output "tcp_target_group_arns" {
  description = "ARNs of all the target groups. Useful for passing to your Auto Scaling group module."
  value       = "${module.lb-tcp.target_group_arns}"
}

output "tcp_target_group_http_ids" {
  description = "IDs of the HTTP target groups"
  value       = "${module.lb-tcp.target_group_http_ids}"
}

output "tcp_target_group_https_ids" {
  description = "IDs of the HTTPS target groups"
  value       = "${module.lb-tcp.target_group_https_ids}"
}

output "tcp_target_group_tcp_ids" {
  description = "IDs of the TCP target groups"
  value       = "${module.lb-tcp.target_group_tcp_ids}"
}

output "tcp_target_group_ids" {
  description = "IDs of all the target groups"
  value       = "${module.lb-tcp.target_group_ids}"
}

# arn_suffix
# name

//
// Misc
//
output "tcp_principal_account_id" {
  description = "The AWS-owned account given permissions to write your LB logs to S3."
  value       = "${module.lb-tcp.principal_account_id}"
}

//// LB HTTP
//
// LB attributes
//
output "http_arn" {
  description = "ARN of the LB itself. Useful for debug output, for example when attaching a WAF."
  value       = "${module.lb-http.arn}"
}

output "http_dns_name" {
  description = "The DNS name of the LB presumably to be used with a friendlier CNAME."
  value       = "${module.lb-http.dns_name}"
}

output "http_id" {
  description = "The ID of the LB we created."
  value       = "${module.lb-http.id}"
}

output "http_zone_id" {
  description = "The zone_id of the LB to assist with creating DNS records."
  value       = "${module.lb-http.zone_id}"
}

# arn_suffix
# canonical_hosted_zone_id

//
// LB Listener attributes
//
output "http_listener_http_arns" {
  description = "The ARNs of the HTTP LB Listeners"
  value       = "${module.lb-http.listener_http_arns}"
}

output "http_listener_http_ids" {
  description = "The IDs of the HTTP LB Listeners"
  value       = "${module.lb-http.listener_http_ids}"
}

output "http_listener_https_arns" {
  description = "The ARNs of the HTTPS LB Listeners"
  value       = "${module.lb-http.listener_https_arns}"
}

output "http_listener_https_ids" {
  description = "The IDs of the HTTPS LB Listeners"
  value       = "${module.lb-http.listener_https_ids}"
}

output "http_listener_tcp_arns" {
  description = "The ARNs of the network TCP LB Listeners"
  value       = "${module.lb-http.listener_tcp_arns}"
}

output "http_listener_tcp_ids" {
  description = "The IDs of the network TCP LB Listeners"
  value       = "${module.lb-http.listener_tcp_ids}"
}

output "http_listener_arns" {
  description = "ARNs of all the LB Listeners"
  value       = "${module.lb-http.listener_arns}"
}

output "http_listener_ids" {
  description = "IDs of all the LB Listeners"
  value       = "${module.lb-http.listener_ids}"
}

//
// LB Target Group attributes
//
output "http_target_group_http_arns" {
  description = "ARNs of the HTTP target groups. Useful for passing to your Auto Scaling group module."
  value       = "${module.lb-http.target_group_http_arns}"
}

output "http_target_group_https_arns" {
  description = "ARNs of the HTTPS target groups. Useful for passing to your Auto Scaling group module."
  value       = "${module.lb-http.target_group_https_arns}"
}

output "http_target_group_tcp_arns" {
  description = "ARNs of the TCP target groups. Useful for passing to your Auto Scaling group module."
  value       = "${module.lb-http.target_group_tcp_arns}"
}

output "http_target_group_arns" {
  description = "ARNs of all the target groups. Useful for passing to your Auto Scaling group module."
  value       = "${module.lb-http.target_group_arns}"
}

output "http_target_group_http_ids" {
  description = "IDs of the HTTP target groups"
  value       = "${module.lb-http.target_group_http_ids}"
}

output "http_target_group_https_ids" {
  description = "IDs of the HTTPS target groups"
  value       = "${module.lb-http.target_group_https_ids}"
}

output "http_target_group_tcp_ids" {
  description = "IDs of the TCP target groups"
  value       = "${module.lb-http.target_group_tcp_ids}"
}

output "http_target_group_ids" {
  description = "IDs of all the target groups"
  value       = "${module.lb-http.target_group_ids}"
}

# arn_suffix
# name

//
// Misc
//
output "http_principal_account_id" {
  description = "The AWS-owned account given permissions to write your LB logs to S3."
  value       = "${module.lb-http.principal_account_id}"
}

//// LB HTTPS
//
// LB attributes
//
output "https_arn" {
  description = "ARN of the LB itself. Useful for debug output, for example when attaching a WAF."
  value       = "${module.lb-https.arn}"
}

output "https_dns_name" {
  description = "The DNS name of the LB presumably to be used with a friendlier CNAME."
  value       = "${module.lb-https.dns_name}"
}

output "https_id" {
  description = "The ID of the LB we created."
  value       = "${module.lb-https.id}"
}

output "https_zone_id" {
  description = "The zone_id of the LB to assist with creating DNS records."
  value       = "${module.lb-https.zone_id}"
}

# arn_suffix
# canonical_hosted_zone_id

//
// LB Listener attributes
//
output "https_listener_http_arns" {
  description = "The ARNs of the HTTP LB Listeners"
  value       = "${module.lb-https.listener_http_arns}"
}

output "https_listener_http_ids" {
  description = "The IDs of the HTTP LB Listeners"
  value       = "${module.lb-https.listener_http_ids}"
}

output "https_listener_https_arns" {
  description = "The ARNs of the HTTPS LB Listeners"
  value       = "${module.lb-https.listener_https_arns}"
}

output "https_listener_https_ids" {
  description = "The IDs of the HTTPS LB Listeners"
  value       = "${module.lb-https.listener_https_ids}"
}

output "https_listener_tcp_arns" {
  description = "The ARNs of the network TCP LB Listeners"
  value       = "${module.lb-https.listener_tcp_arns}"
}

output "https_listener_tcp_ids" {
  description = "The IDs of the network TCP LB Listeners"
  value       = "${module.lb-https.listener_tcp_ids}"
}

output "https_listener_arns" {
  description = "ARNs of all the LB Listeners"
  value       = "${module.lb-https.listener_arns}"
}

output "https_listener_ids" {
  description = "IDs of all the LB Listeners"
  value       = "${module.lb-https.listener_ids}"
}

//
// LB Target Group attributes
//
output "https_target_group_http_arns" {
  description = "ARNs of the HTTP target groups. Useful for passing to your Auto Scaling group module."
  value       = "${module.lb-https.target_group_http_arns}"
}

output "https_target_group_https_arns" {
  description = "ARNs of the HTTPS target groups. Useful for passing to your Auto Scaling group module."
  value       = "${module.lb-https.target_group_https_arns}"
}

output "https_target_group_tcp_arns" {
  description = "ARNs of the TCP target groups. Useful for passing to your Auto Scaling group module."
  value       = "${module.lb-https.target_group_tcp_arns}"
}

output "https_target_group_arns" {
  description = "ARNs of all the target groups. Useful for passing to your Auto Scaling group module."
  value       = "${module.lb-https.target_group_arns}"
}

output "https_target_group_http_ids" {
  description = "IDs of the HTTP target groups"
  value       = "${module.lb-https.target_group_http_ids}"
}

output "https_target_group_https_ids" {
  description = "IDs of the HTTPS target groups"
  value       = "${module.lb-https.target_group_https_ids}"
}

output "https_target_group_tcp_ids" {
  description = "IDs of the TCP target groups"
  value       = "${module.lb-https.target_group_tcp_ids}"
}

output "https_target_group_ids" {
  description = "IDs of all the target groups"
  value       = "${module.lb-https.target_group_ids}"
}

# arn_suffix
# name

//
// Misc
//
output "https_principal_account_id" {
  description = "The AWS-owned account given permissions to write your LB logs to S3."
  value       = "${module.lb-https.principal_account_id}"
}
