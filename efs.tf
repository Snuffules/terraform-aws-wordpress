####################################################################
# EFS for FS sharing
####################################################################

resource "aws_efs_file_system" "efs" {
   creation_token = "efs"
   performance_mode = "generalPurpose"
   throughput_mode = "bursting"
   encrypted = true
 tags = {
     Name = "EFS"
   }
 }

resource "aws_efs_mount_target" "efs-mt-1" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private1.id
  security_groups = [aws_security_group.efs-sg.id]
}

resource "aws_efs_mount_target" "efs-mt-2" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private2.id
  security_groups = [aws_security_group.efs-sg.id]
}

resource "aws_efs_mount_target" "efs-mt-3" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private3.id
  security_groups = [aws_security_group.efs-sg.id]
}

##################################
#EFS Backup policy
#################################
resource "aws_efs_backup_policy" "efs-backup-policy" {
  file_system_id = aws_efs_file_system.efs.id

  backup_policy {
    status = "ENABLED"
  }
}

