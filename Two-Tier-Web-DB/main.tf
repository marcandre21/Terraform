#main.tf
# Create the custom VPC
resource "aws_vpc" "web-db_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "web-db_vpc"
  }
}
# Create the Public Subnets
resource "aws_subnet" "web-db_pub-sub1" {
  vpc_id                  = aws_vpc.web-db_vpc.id
  cidr_block              = var.pub_subnet1_cidr_block
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "web-db_pub-sub1"
  }
}
resource "aws_subnet" "web-db_pub-sub2" {
  vpc_id                  = aws_vpc.web-db_vpc.id
  cidr_block              = var.pub_subnet2_cidr_block
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "web-db_pub-sub2"
  }
}
# Create the Private Subnets
resource "aws_subnet" "web-db_pvt-sub1" {
  vpc_id                  = aws_vpc.web-db_vpc.id
  cidr_block              = var.pvt_subnet1_cidr_block
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "web-db_pvt-sub1"
  }
}
resource "aws_subnet" "web-db_pvt-sub2" {
  vpc_id                  = aws_vpc.web-db_vpc.id
  cidr_block              = var.pvt_subnet2_cidr_block
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "web-db_pvt-sub2"
  }
}

# Create the Internet Gateway
resource "aws_internet_gateway" "web-db_igw" {
  tags = {
    Name = "web-db_igw"
  }
  vpc_id = aws_vpc.web-db_vpc.id
}

# Create the Route Table
resource "aws_route_table" "web-db_rt" {
  tags = {
    Name = "web-db_rt"
  }
  vpc_id = aws_vpc.web-db_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web-db_igw.id
  }
}

# Create the Route Table Association
resource "aws_route_table_association" "web-db_rt-as1" {
  subnet_id      = aws_subnet.web-db_pub-sub1.id
  route_table_id = aws_route_table.web-db_rt.id
}

resource "aws_route_table_association" "web-db_rt-as2" {
  subnet_id      = aws_subnet.web-db_pub-sub2.id
  route_table_id = aws_route_table.web-db_rt.id
}


# Create the Load balancer
resource "aws_lb" "web-db-lb" {
  name               = "web-db-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web-db_alb-sg.id]
  subnets            = [aws_subnet.web-db_pub-sub1.id, aws_subnet.web-db_pub-sub2.id]

  tags = {
    Environment = "web-db-lb"
  }
}

resource "aws_lb_target_group" "web-db-lb-tg" {
  name     = "web-db-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.web-db_vpc.id
}

# Create the Load Balancer listener
resource "aws_lb_listener" "web-db-lb-listener" {
  load_balancer_arn = aws_lb.web-db-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-db-lb-tg.arn
  }
}

# Create the Target group
resource "aws_lb_target_group" "web-db-lb-target" {
  name       = "target"
  depends_on = [aws_vpc.web-db_vpc]
  port       = "80"
  protocol   = "HTTP"
  vpc_id     = aws_vpc.web-db_vpc.id

}

resource "aws_lb_target_group_attachment" "web-db_tg-attach1" {
  target_group_arn = aws_lb_target_group.web-db-lb-target.arn
  target_id        = aws_instance.nginx_server1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "web-db_tg-attach2" {
  target_group_arn = aws_lb_target_group.web-db-lb-target.arn
  target_id        = aws_instance.nginx_server2.id
  port             = 80
}

# Subnet group for database
resource "aws_db_subnet_group" "web-db_db-sub" {
  name       = "web-db_db-sub"
  subnet_ids = [aws_subnet.web-db_pvt-sub1.id, aws_subnet.web-db_pvt-sub2.id]
}
# Create the Security Group for web servers
resource "aws_security_group" "web-db_web-sg" {
  name        = "web-db_web-sg"
  description = "Allow traffic from VPC"
  vpc_id      = aws_vpc.web-db_vpc.id
  depends_on = [
    aws_vpc.web-db_vpc
  ]

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
  }
  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-db_web-sg"
  }
}

# Create Load balancer security group
resource "aws_security_group" "web-db_alb-sg" {
  name        = "web-db_alb-sg"
  description = "load balancer security group"
  vpc_id      = aws_vpc.web-db_vpc.id
  depends_on = [
    aws_vpc.web-db_vpc
  ]


  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "web-db_alb-sg"
  }
}

# Create Security group for Database
resource "aws_security_group" "web-db_db-sg" {
  name        = "web-db_db-sg"
  description = "allow traffic from internet"
  vpc_id      = aws_vpc.web-db_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web-db_web-sg.id]
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web-db_web-sg.id]
    cidr_blocks     = ["10.1.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}