###################################################
 # Output the necessary information after deployment
###################################################

output "wordpress_rds_endpoint" {
  value = aws_db_instance.wordpress_rds.endpoint
}

output "access" {
  value = "http://${aws_instance.wordpress.public_ip}/index.php"
}

output "lb_fqdn" {
    description = "The LB fully qualified domain name."
    value = aws_lb.wordpress_lb.dns_name
}

output "ec2_ip" {
    description = "WordPress EC2 instance IP address."
    value = aws_instance.wordpress.public_ip
}

output "ec2_ssh_IP" {
  value       = aws_instance.wordpress.public_ip
  sensitive   = false
  description = "EC2 Pulic IP for SSH"
}


