data "terraform_remote_state" "state_file" {
	backend = "s3"
	config {
		bucket	= "vkas-test-bucket"
		key		= "terraform_s3.tfstate"
		region  = "${var.region}"
		encrypt	= true
	}
}

data "aws_availability_zones" "all" {}

# launch configuration for auto scaling group
resource "aws_launch_configuration" "web" {
	image_id		= "${var.ec2_ami}"
	instance_type	= "${var.ec2_type}"
	security_groups = ["${aws_security_group.sg_ec2.id}"]

/*	user_data = <<-EOF
				#!/bin/bash
				echo "Hello, World" > index.html
				nohup busybox httpd -f -p "${var.server_port}" &
				EOF
	# <<-EOF” and “EOF” are Terraform’s heredoc syntax, which allows you to create multiline strings without having to put “\n” all over the place */
	user_data = "${file("user-data.sh")}"
# user_data = "${file("${path.module}/user-data.sh")}"	
	lifecycle {
		create_before_destroy = true
	}
}

# auto scaling group
resource "aws_autoscaling_group" "asg" {
	launch_configuration = "${aws_launch_configuration.web.id}"
	availability_zones = ["${data.aws_availability_zones.all.names}"]
	min_size = "2"
	max_size = "3"
	load_balancers = ["${aws_elb.elb.name}"]
	health_check_type = "ELB"
	tag {
		key = "Name"
		value = "terra-ec2-as"
		propagate_at_launch = true
	}
}

# Create security group
resource "aws_security_group" "sg_ec2" {	
	name	= "sg_ec2"
	description	= "allow all inbound traffic"
	tags {
		Name	= "sg_ec2"
	}
	ingress {
		from_port	= "${var.server_port}"
		to_port		= "${var.server_port}"
		protocol	= "tcp"
		cidr_blocks	= ["0.0.0.0/0"]
	}
	egress {
		from_port	= 0
		to_port		= 0
		protocol	= "-1"
		cidr_blocks	= ["0.0.0.0/0"]
	}
	lifecycle {
		create_before_destroy = true
	}
}

resource "aws_security_group" "sg_elb" {
	name = "sg_elb"
	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "elb" {
	name = "terra-elb"
	security_groups = ["${aws_security_group.sg_elb.id}"]
	availability_zones = ["${data.aws_availability_zones.all.names}"]
	health_check {
		healthy_threshold = 2
		unhealthy_threshold = 2
		timeout = 3
		interval = 30
		target = "HTTP:${var.server_port}/"
	}
	listener {
		lb_port = 80
		lb_protocol = "http"
		instance_port = 8080
		instance_protocol = "http"
	}
}