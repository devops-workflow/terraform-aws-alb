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
