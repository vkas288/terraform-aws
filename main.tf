data "terraform_remote_state" "state_file" {
	backend = "s3"
	config {
		bucket	= "vkas-test-bucket"
		key		= "terraform_s3.tfstate"
		region  = "us-east-2"
	}
}

# Create a web server
resource "aws_instance" "web" {
	ami				= "ami-0f65671a86f061fcd"
	instance_type	= "t2.micro"
	tags {
		Name	= "terra_ec2"
	}
	vpc_security_group_ids = ["${aws_security_group.terra_sg.id}"]
}

# Create security group
resource "aws_security_group" "terra_sg" {	
	name	= "terra_sg"
	description	= "allow all inbound traffic"
	tags {
		Name	= "terra_sg"
	}
	ingress {
		from_port	= 22
		to_port		= 22
		protocol	= "tcp"
		cidr_blocks	= ["110.225.242.177/32"]
	}
	egress {
		from_port	= 0
		to_port		= 0
		protocol	= "-1"
		cidr_blocks	= ["0.0.0.0/0"]
	}
}