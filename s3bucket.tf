#####################################################################################
 # Data source to get the Account ID of the AWS Elastic Load Balancing Service Account
 # in a given region for the purpose of whitelisting in S3 bucket policy.
#####################################################################################

data "aws_elb_service_account" "main" {}
data "aws_caller_identity" "current" {}

###########################################################
 # WordPress content S3 bucket IAM role, policy and profile
###########################################################

###########################
 # Attached to EC2 instances 
###########################

resource "aws_iam_instance_profile" "wordpress" {
  name = "WordPressS3Profile"
  role = "${aws_iam_role.wordpress.name}"
}

resource "aws_iam_role" "wordpress" {
  name = "WordPressS3Role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]

}
EOF

  tags = "${var.tags}"
}

resource "aws_iam_role_policy" "wordpress" {
  name = "WordPressS3Policy"
  role = "${aws_iam_role.wordpress.id}"

  policy = <<EOF
{
	"Version": "2012-10-17",
	
	"Statement": [
	{
		"Effect": "Allow",
		"Action": [
			"s3:CreateBucket",
			"s3:DeleteObject",
			"s3:Put*",
			"s3:Get*",
			"s3:List*"
		],
		"Resource": [
			"${aws_s3_bucket.wordpress.arn}",
			"${aws_s3_bucket.wordpress.arn}/*"
		]
	}
	]
}
EOF
}


#############
# S3 Buckets
#############

resource "aws_s3_bucket" "wordpress" {
/*   acl           =  [aws_s3_bucket_acl] */
  bucket        = "${var.s3_bucket_name}"
  force_destroy = true
  tags = "${var.tags}"
}

resource "aws_s3_bucket" "lb_logs" {
  bucket        = "${var.s3_lblogs_bucket_name}"
  force_destroy = true
  tags = "${var.tags}"
}

/* resource "aws_s3_bucket_policy" "lb_logs_policy" {
  bucket = aws_s3_bucket.lb_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "wordpress-buck-policy"
        Effect = "Allow"
        Action = "s3:PutObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.lb_logs.id}/*"
        Principal = { AWS = [data.aws_elb_service_account.main.arn] }
      }
    ]
  })
} */

#################################
 # Access Logs for Load Ballancer
################################# 

data "aws_iam_policy_document" "allow_load_balancer_write" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["${data.aws_elb_service_account.main.arn}"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.lb_logs.arn}/Wordpress-LB/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "access_logs" {
    bucket = "${aws_s3_bucket.lb_logs.id}"
    policy = data.aws_iam_policy_document.allow_load_balancer_write.json
}

###############################
 #S3 Versioning and encryption 
##############################

resource "aws_s3_bucket_versioning" "wordpress_s3_bucket_versioning" {
  bucket = aws_s3_bucket.wordpress.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "wordpress_crypto_conf-wordpress" {
  bucket        = aws_s3_bucket.wordpress.bucket 
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "lb_logs_s3_bucket_versioning" {
  bucket = aws_s3_bucket.lb_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lb_logs_s3_crypto_conf-wordpress" {
  bucket        = aws_s3_bucket.lb_logs.bucket 
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}