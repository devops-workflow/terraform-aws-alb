data "aws_vpc" "vpc" {
  tags {
    Env = "one"
  }
}
# Look up security group
data "aws_subnet_ids" "public_subnet_ids" {
  vpc_id = "${data.aws_vpc.vpc.id}"
  tags {
    Network = "Public"
  }
}
data "aws_subnet_ids" "private_subnet_ids" {
  vpc_id = "${data.aws_vpc.vpc.id}"
  tags {
    Network = "Private"
  }
}

# TODO: setup at least 3 LB: NLB, ALB w/o logs, ALB w/ logs
#   update outputs for all 3
module "lb-tcp" {
  source              = "../"
  name                = "lb-tcp"
  environment         = "one"
  organization        = "wiser"
  #attributes      = ["role", "policy", "use", ""]
  #tags            = "${map("Key", "Value")}"
  #enabled             = false
  #health_check_path   = ""
  security_groups     = ["sg-a5bf1cd8"]  # Need at least 1
  lb_protocols        = ["HTTP","HTTPS"]
  type                = "network"
  subnets             = "${data.aws_subnet_ids.private_subnet_ids.ids}"
  vpc_id              = "${data.aws_vpc.vpc.id}"
  ports                 = "3000,4000"
  instance_http_ports   = "80,8080"
  instance_https_ports  = "443"
  instance_tcp_ports    = ""
  lb_http_ports         = "80,8080"
  lb_https_ports        = "443"
  lb_tcp_ports          = ""
}
module "lb-http" {
  source              = "../"
  name                = "lb-http"
  environment         = "one"
  organization        = "wiser"
  #attributes      = ["role", "policy", "use", ""]
  #tags            = "${map("Key", "Value")}"
  #enabled             = false
  #health_check_path   = ""
  security_groups     = ["sg-a5bf1cd8"]  # Need at least 1
  lb_protocols        = ["HTTP"]
  #type                = "network"
  subnets             = "${data.aws_subnet_ids.private_subnet_ids.ids}"
  vpc_id              = "${data.aws_vpc.vpc.id}"
  ports                 = "3000,4000"
  instance_http_ports   = "80,8080"
  instance_https_ports  = ""
  instance_tcp_ports    = ""
  lb_http_ports         = "80,8080"
  lb_https_ports        = ""
  lb_tcp_ports          = ""
}
module "lb-https" {
  source              = "../"
  name                = "lb-https"
  environment         = "one"
  organization        = "wiser"
  #attributes      = ["role", "policy", "use", ""]
  #tags            = "${map("Key", "Value")}"
  #enabled             = false
  #health_check_path   = ""
  internal            = false # PUBLIC
  #security_groups     = ["sg-a5bf1cd8"]  # Need at least 1
  security_groups     = ["sg-422c923e"] #  PUBLIC -> use whitelist SG
  lb_protocols        = ["HTTPS"]
  #type                = "network"
  #subnets             = "${data.aws_subnet_ids.private_subnet_ids.ids}"
  subnets             = "${data.aws_subnet_ids.public_subnet_ids.ids}" # PUBLIC -> use public subnets
  vpc_id              = "${data.aws_vpc.vpc.id}"
  ports                 = "3000,4000"
  instance_http_ports   = ""
  instance_https_ports  = "443,8443"
  instance_tcp_ports    = ""
  lb_http_ports         = ""
  lb_https_ports        = "443,8443"
  lb_tcp_ports          = ""
}
