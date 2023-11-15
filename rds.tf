##########################
 # RDS Instance for MariaDB
##########################
resource "aws_db_instance" "wordpress_rds" {
  db_name              = "mydb"
  allocated_storage    = 20
  storage_type         = "gp3"
  engine               = "mariadb"
  engine_version       = "10.5"
  instance_class       = "db.t2.micro"
  username             = "admin"
  password             = "wordpressdb"
  parameter_group_name = "default.mariadb10.5"
  db_subnet_group_name = aws_db_subnet_group.wordpress_db_subnets_group.name
  vpc_security_group_ids = [aws_security_group.mysql.id]
  skip_final_snapshot  = true
  multi_az             = "true"
  
#########################
 # Enable automated backups
##########################
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:05:00-sun:06:00"  
  tags = "${var.tags}"
}
