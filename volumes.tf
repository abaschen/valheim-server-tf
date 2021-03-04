resource "aws_efs_file_system" "app-fs" {
  tags = {
    Application = var.appname
  }
}

locals {
    subnet_volumes = [for pair in setproduct(var.container.volumes, aws_subnet.default_subnet) : {
      volume_key = pair[0].key
      subnet_key  = pair[1].key
    }]

    #for_each = {for subnet_volume in local.subnet_volumes : "${subnet_volume.volume_key}.${subnet_volume.subnet_key}" => subnet_volume}
}

resource "aws_efs_mount_target" "mount" {

  for_each = [for subnet in aws_subnet.default_subnet: subnet.id]

  file_system_id = aws_efs_file_system.app-fs.id
  subnet_id      = each.value

  security_groups = [aws_security_group.efs.id]

}

resource "aws_security_group" "efs" {
  name        = "efs-mnt"
  description = "Allows NFS traffic from instances within the VPC."
  vpc_id      = aws_vpc.default_vpc.id

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = [aws_vpc.default_vpc.cidr_block]
  }

  egress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = [aws_vpc.default_vpc.cidr_block]
  }

  tags = {
    Application = var.appname
  }
}