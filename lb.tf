
resource "aws_lb" "application_lb" {
  name               = "flaskapp-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = ["${aws_subnet.public_1.id}","${aws_subnet.public_2.id}"]

  tags = {
    name = "flaskapp_lb"
  }
}

#Create a security group for the load balancer:
resource "aws_security_group" "lb_sg" {
    name = "alb_security_group"
    vpc_id = aws_vpc.flask_vpc.id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic in from all sources
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTP"
  # target_type = "ip"
  vpc_id      = aws_vpc.flask_vpc.id # default VPC

  tags = {
    name = "flaskapp_target_group"

  }
}

resource "aws_lb_listener" "flaskapp_listener" {
  load_balancer_arn = aws_lb.application_lb.arn #  load balancer
  port              = 443
  protocol          = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.ecs_domain_certificate.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn # target group
  }
   depends_on = [aws_acm_certificate_validation.ecs_domain_certificate_validation]
}

resource "aws_lb_listener" "flaskapp_listener_https_redirect" {
  load_balancer_arn = aws_lb.application_lb.arn #  load balancer
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


resource "aws_launch_configuration" "as_conf" {
image_id = "ami-0fb2f0b847d44d4f0"
iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
security_groups = [aws_security_group.flaskapp_sg.id]
user_data = "#!/bin/bash\necho ECS_CLUSTER=flaskapp_cluster >> /etc/ecs/ecs.config"
instance_type = "t2.micro"
}

# resource "aws_launch_configuration" "ecs_launch_config" {
# image_id = "ami-094d4d00fd7462815"
# iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
# security_groups = [aws_security_group.flaskapp_sg.id]
# user_data = "#!/bin/bash\necho ECS_CLUSTER=my-cluster >> /etc/ecs/ecs.config"
# instance_type = "t2.micro"

# }

resource "aws_autoscaling_group" "ecs_asg" {
name = "asg"
vpc_zone_identifier = [aws_subnet.public_1.id, aws_subnet.public_2.id]
launch_configuration = aws_launch_configuration.as_conf.name
desired_capacity = 2
min_size = 1
max_size = 10
health_check_grace_period = 300
health_check_type = "EC2"
target_group_arns = [aws_lb_target_group.target_group.arn]
}


