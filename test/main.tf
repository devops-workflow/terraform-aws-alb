module "lb" {
  source          = "../"
  name            = "lb-svc"
  environment     = "testing"
  organization    = ""
  #attributes      = ["role", "policy", "use", ""]
  #tags            = "${map("Key", "Value")}"
  #enabled         = false
}
