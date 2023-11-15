#####################################################################
 # CloudWatch Autoscale EC2 CPU Metric
#####################################################################

resource "aws_autoscaling_policy" "wp-cpu" {
  name                   = "terraform-cpu-load-wp"
  scaling_adjustment     = 4
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_cloudwatch_metric_alarm" "wp-cpu" {
  alarm_name          = "terraform-cpu-load-wp"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.wp-cpu.arn]
}

#######################################
 # CloudWatch RDS DB CONNECTIONS Metric
#######################################

resource "aws_cloudwatch_metric_alarm" "too_many_db_connections" {
  alarm_name          = "too_many_db_connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = var.db_connection_threshold
  alarm_description   = "Average db connections over last 10 minutes is too high"
  alarm_actions       = [aws_sns_topic.topic.arn]
  ok_actions          = [aws_sns_topic.topic.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.wordpress_rds.id
  }
}

#########################################
 # CloudWatch RDS CPU UTIULIZATION Metric
#########################################

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_too_high" {
  alarm_name          = "cpu_utilization_too_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = var.cpu_utilization_threshold
  alarm_description   = "Average database CPU utilization over last 10 minutes too high"
  alarm_actions       = [aws_sns_topic.topic.arn]
  ok_actions          = [aws_sns_topic.topic.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.wordpress_rds.id
  }
}