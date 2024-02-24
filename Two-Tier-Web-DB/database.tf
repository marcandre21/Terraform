#database.tf
# RDS MYSQL database
resource "aws_db_instance" "my_db1" {
  allocated_storage           = 5
  storage_type                = "gp2"
  engine                      = "mysql"
  engine_version              = "5.7"
  instance_class              = "db.t2.micro"
  db_subnet_group_name        = "web-db_db-sub"
  vpc_security_group_ids      = [aws_security_group.web-db_db-sg.id]
  parameter_group_name        = "default.mysql5.7"
  db_name                     = "my_database"
  username                    = "admin"
  password                    = "password$"
  allow_major_version_upgrade = true
  auto_minor_version_upgrade  = true
  backup_retention_period     = 35
  backup_window               = "21:00-22:00"
  maintenance_window          = "Sat:01:00-Sat:03:00"
  multi_az                    = false
  skip_final_snapshot         = true
}