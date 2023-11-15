##########################
 #Create Backup Vault
 #########################

resource "aws_backup_vault" "wordpress-backup-vault" {
  name        = "ewordpress-backup-vault"
}

#########################
 #Create Backup Plan
######################### 

resource "aws_backup_plan" "wordpress-backup-plan" {
  name = "wp-backup-plan"

  rule {
    rule_name         = "wordpress-backup-plan_backup_rule"
    target_vault_name = aws_backup_vault.wordpress-backup-vault.name
    schedule          = "cron(0 12 * * ? *)"

    lifecycle {
      delete_after = 14
    }
  }

  advanced_backup_setting {
    backup_options = {
      WindowsVSS = "enabled"
    }
    resource_type = "EC2"
  }
}