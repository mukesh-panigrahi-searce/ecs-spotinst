provider "spotinst" {
   token   = "${var.spotinst_token}"
   account = "${var.spotinst_account}"
}

# Create an Elastigroup
resource "spotinst_elastigroup_aws" "default-elastigroup" {

  name        = "ecs-elastigroup"
  description = "created by Terraform"
  product     = "Linux/UNIX"

  max_size          = 3
  min_size          = 1
  desired_capacity  = 2
  capacity_unit     = "weight"

  region      = "${var.aws_region}"
  subnet_ids  = ["subnet-91da33cd", "subnet-7751ec3d", "subnet-411ef56f"]

  image_id              = "ami-0361adb513f74d321"
  iam_instance_profile  = "test-ecs-role"
  key_name              = "aws-general-key"
  security_groups       = ["sg-05fc95ed5f04eb9a3"]
  user_data             = ""
  enable_monitoring     = false
  ebs_optimized         = false
  placement_tenancy     = "default"

  instance_types_ondemand       = "t3.micro"
  instance_types_spot           = ["c4.large", "r4.large"]
  instance_types_preferred_spot = ["t2.large"]

  instance_types_weights {
    instance_type = "r4.large"
    weight        = 5
  }

  instance_types_weights {
    instance_type = "c4.large"
    weight        = 3
  }

  orientation           = "balanced"
  fallback_to_ondemand  = false
  cpu_credits           = "unlimited"

  wait_for_capacity         = 5
  wait_for_capacity_timeout = 300

  scaling_strategy {
    terminate_at_end_of_billing_hour = true
    termination_policy = "default"
  }

  scaling_up_policy {
    policy_name = "policy-name"
    metric_name = "CPUUtilization"
    namespace   = "AWS/EC2"
    source      = "cloudWatch"
    statistic   = "average"
    unit        = "percent"
    cooldown    = 60
    is_enabled  = false

    threshold          = 10
    operator           = "gte"
    evaluation_periods = 10
    period             = 60

    action_type = "updateCapacity"
    minimum     = 0
    maximum     = 10
    target      = 5

  }

  scaling_down_policy {
    policy_name = "policy-name"
    metric_name = "CPUUtilization"
    namespace   = "AWS/EC2"
    source      = "cloudWatch"
    statistic   = "average"
    unit        = "percent"
    cooldown    = 60
    is_enabled  = false

    threshold          = 10
    operator           = "lte"
    evaluation_periods = 10
    period             = 60

    action_type = "updateCapacity"
    minimum     = 0
    maximum     = 10
    target      = 5

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
