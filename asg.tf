data "template_file" "user_data" {
  template = file("${path.module}/wordpress-init.sh")
  vars = {
    efs_dns_name = var.efs_dns_name
  }
}



#######################################
 #Create Autoscaling Group
#######################################
resource "aws_launch_template" "asg-lt-wp" {
  name_prefix   = "asg-lt-wp"
  image_id      = "ami-0694d931cee176e7d"
  instance_type = "t2.micro"
  network_interfaces {
      delete_on_termination       = true
      description                 = "eth0"
      device_index                = 0
      security_groups             = [aws_security_group.web.id]
      associate_public_ip_address = true
  }  
  user_data = base64encode(templatefile("${path.module}/wordpress-init.sh",

     {
       vars = {
        efs_dns_name = resource.aws_efs_file_system.efs.dns_name
       }
  }))
}      

resource "aws_autoscaling_group" "asg" {
  desired_capacity   = 1
  max_size           = 4
  min_size           = 1
  vpc_zone_identifier = [aws_subnet.private1.id, aws_subnet.private2.id, aws_subnet.private3.id]
  target_group_arns = [aws_lb_target_group.wordpress_tg.arn]

  launch_template {
    id      = aws_launch_template.asg-lt-wp.id
    version = "$Latest"
  }
}

resource "aws_instance" "wordpress" {
/*   ami             = "ami-0694d931cee176e7d" 
  instance_type   = "t2.micro" */
  subnet_id       = aws_subnet.public1.id
  launch_template {
    id      = aws_launch_template.asg-lt-wp.id
    version = "$Latest"
  }
  volume_tags = "${var.tags}"    
}

