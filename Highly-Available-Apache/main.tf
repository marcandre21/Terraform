# main.tf - AWS Terraform configuration script
# AWS provider configuration
provider "aws" {
  region = var.region
}
# Key pair resource
resource "aws_key_pair" "my_keypair" {
  key_name   = var.key_name
  public_key = tls_private_key.my_keypair.public_key_openssh
}
# TLS private key resource
resource "tls_private_key" "my_keypair" {
  algorithm = "RSA"
}
# Launch configuration for EC2 instances
resource "aws_launch_configuration" "my_apache_config" {
  name            = "my_launch_configuration"
  image_id        = var.image_id
  instance_type   = var.instance_type
  user_data       = file("${path.module}/apache-user_data.sh")
  key_name        = aws_key_pair.my_keypair.key_name
  security_groups = [aws_security_group.my_apache_SG.id]
  provisioner "local-exec" {
    command = <<-EOF
     echo '${tls_private_key.my_keypair.private_key_pem}' > ./private_key.pem
     chmod 400 ./private_key.pem
   EOF
  }
}
# Security group for EC2 instances
resource "aws_security_group" "my_apache_SG" {
  name        = var.security_group_name
  description = "Allow SSH and HTTP traffic"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Application Load Balancer (ALB) resource
resource "aws_lb" "my_apache_alb" {
  name                             = "Apache-lb"
  internal                         = false
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.my_apache_alb_SG.id]
  subnets                          = var.vpc_zone_identifiers
  enable_deletion_protection       = false
  enable_http2                     = true
  enable_cross_zone_load_balancing = true
  tags = {
    Name = "Apache-lb"
  }
}
# ALB Target Group
resource "aws_lb_target_group" "my_target_group" {
  name        = "my-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_lb.my_apache_alb.vpc_id

  health_check {
    path                = "/"
    enabled             = true
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
  }
}
# Listener Rule for ALB
resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_apache_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}
# Security group for ALB
resource "aws_security_group" "my_apache_alb_SG" {
  name        = "alb-security-group"
  description = "Allow traffic from the internet to ALB"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Autoscaling group for EC2 instances
resource "aws_autoscaling_group" "my_apache_ASG" {
  desired_capacity     = 2
  max_size             = 5
  min_size             = 2
  vpc_zone_identifier  = var.vpc_zone_identifiers
  launch_configuration = aws_launch_configuration.my_apache_config.id

  # ALB association
  health_check_type         = "ELB"
  health_check_grace_period = 300
  tag {
    key                 = "Name"
    value               = "my-asg-instance"
    propagate_at_launch = true
  }
}
# Attach autoscaling group to ALB
resource "aws_autoscaling_attachment" "apache-asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.my_apache_ASG.name
  lb_target_group_arn    = aws_lb_target_group.my_target_group.arn
}
# Modify Autoscaling group security group to only allow traffic from the ALB
resource "aws_security_group_rule" "alb_ingress" {
  security_group_id        = aws_security_group.my_apache_SG.id
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.my_apache_alb_SG.id
}