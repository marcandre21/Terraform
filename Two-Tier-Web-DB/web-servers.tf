#web-servers.tf
# Public subnet for web server 1
resource "aws_instance" "nginx_server1" {
  ami             = "ami-0e731c8a588258d0d"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web-db_web-sg.id]
  subnet_id       = aws_subnet.web-db_pub-sub1.id
  key_name        = "us-east-kp"
  user_data       = file("${path.module}/nginx-user_data.sh")

  tags = {
    Name = "nginx_server1"
  }
}

# Public subnet for web server 2
resource "aws_instance" "nginx_server2" {
  ami             = "ami-0e731c8a588258d0d"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web-db_web-sg.id]
  subnet_id       = aws_subnet.web-db_pub-sub2.id
  key_name        = "us-east-kp"
  user_data       = file("${path.module}/nginx-user_data.sh")

  tags = {
    Name = "nginx_server2"
  }
}

#Elastic IPs for web servers

resource "aws_eip" "nginx_server1-eip" {
  vpc = true

  instance   = aws_instance.nginx_server1.id
  depends_on = [aws_internet_gateway.web-db_igw]
}

resource "aws_eip" "nginx_server2-eip" {
  vpc = true

  instance   = aws_instance.nginx_server2.id
  depends_on = [aws_internet_gateway.web-db_igw]
}