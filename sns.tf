###############################
 # Simple Notification Service
###############################

resource "aws_sns_topic" "topic" {
  name = "my-sns-topic"
}

resource "aws_sns_topic_subscription" "subscription" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "email" // or "sms", "lambda", etc.
  endpoint  = "snuff.mcloud@gmail.com" // your email address or endpoint for the selected protocol
}
