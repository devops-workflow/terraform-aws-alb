
provider "aws" {
  region  = "${var.region}"
  version = "1.5"
  # Can not upgrade until bugs introduced in 1.6 are fixed
}
