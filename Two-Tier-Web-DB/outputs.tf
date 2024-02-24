#outputs.tf
#Output web servers public IPs and MySQL db arn
output "nginx_server1_ip" {
  value = aws_instance.nginx_server1.public_ip
}

output "nginx_server2_ip" {
  value = aws_instance.nginx_server2.public_ip
}

output "my_db1_arn" {
  value = aws_db_instance.my_db1.arn
}