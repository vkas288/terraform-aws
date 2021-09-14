terraform {
  required_version = "> 0.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {}

data "aws_ami" "web_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.web_ami.id
  instance_type = lookup(var.instance_type, terraform.workspace)

  #count = var.instance_type == "t2.micro" ? 1 : 0
}

output "instance_id" {
  value     = aws_instance.web[*].id
}

variable "instance_type" {
  type        = map(any)                  # optional
  description = "enter the instance type" # optional

  default = {
    default = "t2.micro" # optional
    dev     = "t2.small"
    prod    = "t2.medium"
  }

}
