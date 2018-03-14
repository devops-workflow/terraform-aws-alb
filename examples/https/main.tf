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

module "lb-https" {
  source               = "../../"
  name                 = "lb-https"
  environment          = "one"
  organization         = "wiser"
  instance_http_ports  = ""
  instance_https_ports = "443,8443"
  instance_tcp_ports   = ""
  internal             = false                                          # PUBLIC
  lb_http_ports        = ""
  lb_https_ports       = "443,8443"
  lb_protocols         = ["HTTPS"]
  lb_tcp_ports         = ""
  ports                = "3000,4000"
  security_groups      = ["sg-bef0a5c2"]                                #  PUBLIC -> use whitelist SG
  subnets              = "${data.aws_subnet_ids.public_subnet_ids.ids}" # PUBLIC -> use public subnets
  vpc_id               = "${data.aws_vpc.vpc.id}"
}
