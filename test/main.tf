module "lb" {
  source              = "../"
  name                = "lb-svc"
  environment         = "testing"
  #organization        = ""
  #attributes      = ["role", "policy", "use", ""]
  #tags            = "${map("Key", "Value")}"
  #enabled             = false
  region              = "us-west-2"
  certificate_arn     = ""
  health_check_path   = ""
  lb_name             = ""
  lb_security_groups  = []
  subnets             = []
  vpc_id              = ""
}
