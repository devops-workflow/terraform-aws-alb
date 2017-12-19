module "lb" {
  source              = "../"
  name                = "lb-svc"
  environment         = "one"
  organization        = "wiser"
  #attributes      = ["role", "policy", "use", ""]
  #tags            = "${map("Key", "Value")}"
  #enabled             = false
  health_check_path   = ""
  security_groups     = []
  lb_protocols        = ["HTTP","HTTPS"]
  type                = "network"
  subnets             = []
  vpc_id              = ""
  ports                 = "3000,4000"
  instance_http_ports   = "80,8080"
  instance_https_ports  = "443"
  instance_tcp_ports    = ""
  lb_http_ports         = "80,8080"
  lb_https_ports        = "443"
  lb_tcp_ports          = ""

}

/* Example for replacing existing module
module "lb-http-service" {
  source                = "../"
  name                  = "${var.stack}"
  subnets               = "${module.aws_env.private_subnet_ids}"
  vpc_id                = "${module.aws_env.vpc_id}"
  security_groups       = "${compact(split(",", "${join(",", var.additional_sg_ids)},${module.sg.sg_id}" ))}"
  ports                 = "${join(",", list(var.port), var.additional_ports)}"
  type                  = "${var.lb_type}"
  lb_protocols          = ["${var.lb_type == "application" ? "HTTP" : "TCP"}"]
  health_check_path     = "${var.healthcheck_path}"
  health_check_protocol = "${var.healthcheck_protocol}"
}
*/
