# terraform plan -var project_name=test-codebuild-prj -var bucket_name=testbucker -var repo_type=GITHUB -var repo_url=https://github.com/sriharsha-inthub/mule-http-echo.git
#################################################################################

################ CODEBUILD #######################
resource "aws_codebuild_project" "mule-cloudhub-auth" {
  count = "${var.create_mule-cloudhub-auth}" ? 1 : 0
  name          	= "mule-cloudhub-auth"
  description  		= "Mule application cloudhub authentication"
  build_timeout 	= "${var.build_timeout}"
  service_role  	= "${data.aws_iam_role.selected_codebuild_role.arn}"
  badge_enabled 	= true
  encryption_key 	= "${data.aws_kms_key.aws_s3_Key.id}"
  
  artifacts {
    type     		= "S3"
    location 		= "${var.bucket_name}"
    packaging 		= "NONE"
    namespace_type 	= "NONE"
    name 			= "target"
    path 			= "mulecloudhubauth"
    encryption_disabled = false
  }
  
  cache {
    type     	= "NO_CACHE"
    location 	= ""
    modes 		= [""]	
  }

  environment {
    compute_type 				= "BUILD_GENERAL1_SMALL"
    image        				= "${var.image}"
	  privileged_mode 			= true
    type         				= "LINUX_CONTAINER"
	  image_pull_credentials_type = "CODEBUILD"
	
	environment_variable {
      name  = "APP_NAME"
      value = "cloudhubauth-v1"
	  type 	= "PLAINTEXT"
    }
    environment_variable {
      name  = "MULE_VERSION"
      value = "4.1.5"
      type  = "PLAINTEXT"
    }
	environment_variable {
      name  = "CLOUDHUB_ENV"
      value = "${var.cloudhubEnv}"
      type  = "PLAINTEXT"
    }
	environment_variable {
      name  = "ANYPOINT_LOGIN_URI"
      value = "${var.cloudhubUrl}"
      type  = "PLAINTEXT"
    }
	environment_variable {
      name  = "CLOUDHUB_USERNAME"
      value = "${var.cloudhubUsername}"
      type  = "PARAMETER_STORE"
    }
	environment_variable {
      name  = "CLOUDHUB_PASSWORD"
      value = "${var.cloudhubPassword}"
      type  = "PARAMETER_STORE"
    }
	environment_variable {
      name  = "EFS_ID"
      value = "${var.efs_id}"
      type  = "PARAMETER_STORE"
    }
	
  }

  source {
    type     			= "GITHUB"
    location 			= "https://github.com/sriharsha-inthub/mule-cloudhub-auth.git"
    git_clone_depth 	= 1
    report_build_status = true
    buildspec 			= "cicd/build/buildspec-for-terraform.yml"
	insecure_ssl 		= false
	
	auth {
	  type 		= "OAUTH"
	  resource 	= "${var.github_token}"
	}
  
  }
  
  vpc_config {
    vpc_id = "${data.aws_vpc.selected_vpc.id}"

    subnets = [
      "${data.aws_subnet.selected_privatesubnet_1a.id}",
    ]

    security_group_ids = [
      "${data.aws_security_group.selected_private_sg.id}"
    ]
  }
  
  logs_config {
    cloudwatch_logs {
      group_name 	= "mule-cloudhub-auth"
      stream_name 	= "mule-cloudhub-auth"
    }
    s3_logs {
      status 				= "ENABLED"
      location 				= "${data.aws_s3_bucket.selected_s3bucket.id}/build-logs"
	  encryption_disabled 	= "false"
    }
  }

}

#####	CODEBUILD	#####

output "badge_url-mule-cloudhub-auth" {
  value       =  "${join(",",aws_codebuild_project.mule-cloudhub-auth.*.badge_url)}"
}