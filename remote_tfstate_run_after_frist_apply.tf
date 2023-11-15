#terraform {
  #############################################################
  ## AFTER RUNNING TERRAFORM APPLY (WITH LOCAL BACKEND)
  ## YOU WILL UNCOMMENT THIS CODE THEN RERUN TERRAFORM INIT
  ## TO SWITCH FROM LOCAL BACKEND TO REMOTE AWS BACKEND
  #############################################################
  # backend "s3" {
  #   bucket         = "wordpress-tf-state" # REPLACE WITH YOUR BUCKET NAME
  #   key            = "terraform.tfstate"
  #   region         = "eu-west-1"
  #   access_key     = "AKIA5Q7Z5W47ZF3TPWGT"
  #   secret_key     = "0c84zbi42BVPrrRjzR5ua1ZElIyKW0Jqrof/BMOR"
  #   dynamodb_table = "terraform-state-locking"
  #   encrypt        = true
  # }

resource "aws_s3_bucket" "terraform_state-wordpress" {
  bucket        = "wordpress-tf-state" 
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "terraform_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state-wordpress.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_crypto_conf-wordpress" {
  bucket        = aws_s3_bucket.terraform_state-wordpress.bucket 
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
