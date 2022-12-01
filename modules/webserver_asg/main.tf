#create launch configuration
resource "aws_launch_configuration" "webserver" {
  name   = "techchak-webserver"
  image_id      = "ami-0be3260462977a94d"
  instance_type = "t2.micro"
  security_groups = [var.webserver_security_group_id]
  key_name = "terraform"

  lifecycle {
    create_before_destroy = true
  }

}


#create auto_scaling_group
resource "aws_autoscaling_group" "asg" {
  name                      = "webserver-asg"
  launch_configuration      = aws_launch_configuration.webserver.name
  vpc_zone_identifier       = [var.public_subnet_az1_id, var.public_subnet_az2_id]
  target_group_arns         = [var.alb_target_group_arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  desired_capacity          = 2  
  min_size                  = 1
  max_size                  = 4

}

#create auto_scaling_policy
resource "aws_autoscaling_policy" "auto_scaling_policy" {  
    autoscaling_group_name = aws_autoscaling_group.asg.name
    name = "my-asg-policy"
    adjustment_type = "ChangeInCapacity"
    policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 40.0
  }
}