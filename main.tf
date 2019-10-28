provider "spotinst" {
   token   = "${var.spotinst_token}"
   account = "${var.spotinst_account}"
}

# Create an Elastigroup
resource "spotinst_elastigroup_aws" "default-elastigroup" {

  name        = "spotinst-elastigroup"
  description = "created by Terraform"
  product     = "Linux/UNIX"

  max_size          = 10
  min_size          = 1
  desired_capacity  = 3
  capacity_unit     = "weight"

  region      = "us-east-1"
  subnet_ids  = ["subnet-91da33cd", "subnet-7751ec3d", "subnet-411ef56f"]

  image_id              = "ami-0361adb513f74d321"
  iam_instance_profile  = "test-ecs-mukesh-role"
  key_name              = "aws-general-key"
  security_groups       = ["sg-05fc95ed5f04eb9a3"]
  user_data             = ""
  enable_monitoring     = false
  ebs_optimized         = false
  placement_tenancy     = "default"

  instance_types_ondemand       = "t3.micro"
  instance_types_spot           = ["c4.large", "r4.large"]
  # instance_types_preferred_spot = ["t3.micro"]

  instance_types_weights {
    instance_type = "r4.large"
    weight        = 1
  }

  instance_types_weights {
    instance_type = "c4.large"
    weight        = 5
  }

  orientation           = "balanced"
  fallback_to_ondemand  = false
  cpu_credits           = "unlimited"

  wait_for_capacity         = 1
  wait_for_capacity_timeout = 300

  scaling_strategy {
    terminate_at_end_of_billing_hour = true
    termination_policy = "default"
  }

  tags {
     key   = "Env"
     value = "dev"
  } 

  lifecycle {
    ignore_changes = [
      "desired_capacity",
    ]
  }

  integration_ecs { 
    cluster_name         = "ecs-spotinst"
  }
}
