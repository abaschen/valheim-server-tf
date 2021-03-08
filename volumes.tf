resource "aws_efs_file_system" "app-fs" {
  creation_token = "${var.appname}-efs"
  tags = {
    Application = var.appname
  }
}

resource "aws_efs_mount_target" "mount" {
  count = length(var.subnet_zones)

  file_system_id = aws_efs_file_system.app-fs.id
  subnet_id      = aws_subnet.default_subnet[count.index].id

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

/*  egress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = [aws_vpc.default_vpc.cidr_block]
  }
*/
  tags = {
    Application = var.appname
  }
}