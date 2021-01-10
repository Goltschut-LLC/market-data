#################################################################################################
# Default resources behave differently than normal resources, in that Terraform 
#   does not create these resources, but instead "adopts" them.
#################################################################################################

resource "aws_default_vpc" "default_vpc" {}

resource "aws_default_subnet" "default_az_a" {
  availability_zone = "${data.aws_region.current.name}a"
}

resource "aws_default_subnet" "default_az_b" {
  availability_zone = "${data.aws_region.current.name}b"
}

resource "aws_default_subnet" "default_az_c" {
  availability_zone = "${data.aws_region.current.name}c"
}

resource "aws_default_subnet" "default_az_d" {
  availability_zone = "${data.aws_region.current.name}d"
}

resource "aws_default_subnet" "default_az_e" {
  availability_zone = "${data.aws_region.current.name}e"
}

resource "aws_default_subnet" "default_az_f" {
  availability_zone = "${data.aws_region.current.name}f"
}

resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_default_vpc.default_vpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
