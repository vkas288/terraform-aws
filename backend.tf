terraform {
	backend "s3" {
		bucket		= "vkas-test-bucket"
		key			= "terraform_s3.tfstate"
		region 		= "us-east-2"
		role_arn	= "arn:aws:iam::439462370694:role/terra_s3_role"
	}
}

provider "aws" {
	assume_role {
		role_arn	= "arn:aws:iam::439462370694:role/terra_s3_role"
	}
	region 		= "us-east-2"
}