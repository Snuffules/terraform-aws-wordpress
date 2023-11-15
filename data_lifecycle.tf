##############################################
 # Create a Lifecycle Policy for EBS Snapshots
##############################################

resource "aws_dlm_lifecycle_policy" "example" {
  description        = "EBS Snapshot Lifecycle Policy"
  execution_role_arn = aws_iam_role.dlm-role.arn

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "2-hourly-snapshots"

      create_rule {
        interval      = 2
        interval_unit = "HOURS"
        times         = ["23:45"]
      }

      retain_rule {
        count = 24
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
      }

      copy_tags = false
    }

    target_tags = {
      "Backup" = "True"
    }
  }

  state = "ENABLED"
}

##############################################
 # Create an IAM Role for Data Lifecycle Manager
##############################################

resource "aws_iam_role" "dlm-role" {
  name = "dlm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "dlm.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_policy" "dlm-policy" {
  name   = "dlm-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateSnapshot",
        "ec2:DeleteSnapshot",
        "ec2:DescribeVolumes",
        "ec2:DescribeSnapshots"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "dlm-policy-attach" {
  role       = aws_iam_role.dlm-role.name
  policy_arn = aws_iam_policy.dlm-policy.arn
}
