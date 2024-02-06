# outputs.tf
# Output the Jenkins instance public IP
output "jenkins_instance_ip" {
  value = aws_instance.jenkins_instance.public_ip
}