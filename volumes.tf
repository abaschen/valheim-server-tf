resource "aws_efs_file_system" "app-fs" {
  creation_token = "${var.appname}-efs"
  tags = {
    Application = var.appname
  }
}

resource "aws_efs_mount_target" "mount" {
  for_each = var.subnet_zones

  file_system_id = aws_efs_file_system.app-fs.id
  subnet_id      = aws_subnet.internal_subnets[each.key].id

  security_groups = [aws_security_group.internal-sg.id]

}

# Create the access point with the given user permissions
resource "aws_efs_access_point" "volumes-access-points" {
  for_each = var.container.volumes
  
  file_system_id = aws_efs_file_system.app-fs.id
  posix_user {
    gid = 1000
    uid = 1000
  }
  root_directory {
    path = "/${each.key}"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 755
    }
  }
  tags = {
    Application = var.appname
  }
}