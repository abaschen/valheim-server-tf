resource "aws_ecs_cluster" "cluster" {
  name = "valheim-cluster"
  
  tags = {
    Application  = var.appname
  }
}