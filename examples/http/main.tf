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

module "lb-http" {
  source       = "../../"
  name         = "lb-http"
  environment  = "one"
  organization = "wiser"

  #enable_deletion_protection = true
  #enable_http2         = false
  instance_http_ports = "80,8080"

  instance_https_ports = ""
  instance_tcp_ports   = ""
  lb_http_ports        = "80,8080"
  lb_https_ports       = ""
  lb_protocols         = ["HTTP"]
  lb_tcp_ports         = ""
  ports                = "3000,4000"
  security_groups      = ["sg-bef0a5c2"]                                 # Need at least 1
  subnets              = "${data.aws_subnet_ids.private_subnet_ids.ids}"
  vpc_id               = "${data.aws_vpc.vpc.id}"
}
