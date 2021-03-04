resource "aws_ecs_cluster" "cluster" {
  name = "${var.appname}-cluster"
  
  tags = {
    Application  = var.appname
  }
}