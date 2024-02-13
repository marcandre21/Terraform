# outputs.tf
# Output Auto Scaling Group ID
output "auto_scaling_group_id" {
  value = aws_autoscaling_group.my_apache_ASG.id
}
# Output Security Group ID
output "security_group_id" {
  value = aws_security_group.my_apache_SG.id
}
# Output the public DNS name of the application load balancer
output "alb_dns_name" {
  value = aws_lb.my_apache_alb.dns_name
}