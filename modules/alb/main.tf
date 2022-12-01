# create target group
resource "aws_lb_target_group" "alb_target_group" {
  name        = "${var.project_name}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 60
    matcher             = 200
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  lifecycle {
    create_before_destroy = true 
  }
}

# create application load balancer
resource "aws_lb" "application_load_balancer" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_securitygroup_id]
  subnets            = [var.public_subnet_az1_id, var.public_subnet_az2_id]

  tags   = {
    Environment = "production"
  }
}


# create a listener on port 443 with forward action
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn  = aws_lb.application_load_balancer.arn
  port               = "80"
  protocol           = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}