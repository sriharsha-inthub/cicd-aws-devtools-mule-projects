################ CODEBUILD VPC - DataSources #######################

# Get existing role created part of cicd environment setup
data "aws_iam_role" "selected_codebuild_role" {
    name = "cicd_codebuild_role"
}
# Get vpc details created part of cicd environment setup
data "aws_vpc" "selected_vpc" {
    filter {
        name = "tag:Name"
        values = [ "${var.vpc_name}"]
    }
}

# Get private subnets created part of cicd environment setup
data "aws_subnet" "selected_privatesubnet_1a" {
    vpc_id = "${data.aws_vpc.selected_vpc.id}"
    filter {
        name = "tag:Name"
        values = [ "${var.private_subnet_1a_name}" ]
    }
}

data "aws_subnet" "selected_privatesubnet_1b" {
    count = "${var.enable_ha}" ? 1 : 0
    vpc_id = "${data.aws_vpc.selected_vpc.id}"
    filter {
        name = "tag:Name"
        values = [ "${var.private_subnet_1b_name}" ]
    }
}

data "aws_security_group" "selected_private_sg" {
    filter {
        name = "tag:Name"
        values = [ "${var.sg-private-subnet_name}" ]
    }
}

data "aws_s3_bucket" "selected_s3bucket" {
    bucket = "${var.bucket_name}"
}

data "aws_kms_key" "aws_paramStore_Key" {
  key_id = "alias/aws/ssm"
}

data "aws_kms_key" "aws_s3_Key" {
  key_id = "alias/aws/s3"
}

data "aws_kms_key" "aws_sns_Key" {
  key_id = "alias/aws/sns"
}
