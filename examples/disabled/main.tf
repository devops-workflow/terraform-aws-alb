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

module "disabled" {
  source               = "../../"
  name                 = "lb-disabled"
  environment          = "one"
  organization         = "wiser"
  enabled              = false
  instance_http_ports  = "80,8080"
  instance_https_ports = "443"
  instance_tcp_ports   = ""
  lb_http_ports        = "80,8080"
  lb_https_ports       = "443"
  lb_protocols         = ["HTTP", "HTTPS"]
  lb_tcp_ports         = ""
  ports                = "3000,4000"
  security_groups      = ["sg-bef0a5c2"]                                 # Need at least 1
  subnets              = "${data.aws_subnet_ids.private_subnet_ids.ids}"
  vpc_id               = "${data.aws_vpc.vpc.id}"
}
