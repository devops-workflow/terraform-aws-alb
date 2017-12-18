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
}
