variable "tags" {
  description = "AWS Tags to add to all resources created (where possible); see https://aws.amazon.com/answers/account-management/aws-tagging-strategies/"
  type        = map(any)
  default = {
    Backup      = "True"
    app         = "wordpress",
    environment = "dev"
  }
}
variable "s3_bucket_name" {
  description = "(Optional, Forces new resource) The name of the bucket to host Wordpress objects. If omitted, Terraform will assign a random, unique name."
  default = "wordpress-s3-bucket-snf"
}
variable "s3_lblogs_bucket_name" {
  description = "(Optional, Forces new resource) The name of the bucket to host LB logs. If omitted, Terraform will assign a random, unique name."
  default = "wordpress-s3bucket-lblogs-snf"
}
variable "efs_dns_name" {
  description = "The DNS name of the EFS instance"
  type        = string
  default = ""
}
variable   "vars" {
  default = "efs_dns_name"
  }
variable "db_connection_threshold" {
  default = 60
  }
variable "cpu_utilization_threshold" {
  default = 80
}
variable "aws_access_key" {
  default = "AKIA5Q7Z5W474YNIHURX"
  type = string
  sensitive = true
}
variable "aws_secret_key" {
  default = "gTxc3LTrijejozjcsVEuF8NVgTE4wOfujF3mkEWQ"
  type = string
  sensitive = true
}
variable aws_reg {
  description = "This is aws region"
  default     = "eu-west-1"
  type        = string
}

variable stack {
  description = "this is name for tags"
  default     = "terraform"
}

variable username {
  description = "DB username"
}

variable password {
  description = "DB password"
}

variable dbname {
  description = "db name"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

