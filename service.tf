resource "aws_ecs_service" "valheim-service" {
  name            = "valheim-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.valheim-task.arn
  launch_type     = "FARGATE"
  desired_count   = 1 # only one docker supported

   network_configuration {
    subnets          = aws_subnet.default_subnet[*].id
    assign_public_ip = true
  }

  dynamic "load_balancer" {
    for_each= var.ports
    content{ 
        target_group_arn = aws_lb_target_group.target_group.arn # Referencing our target group
        container_name   = aws_ecs_task_definition.valheim-task.family
        container_port   = load_balancer.value
    }
  }

   tags = {
    Application  = var.appname
  }
}

resource "aws_vpc" "default_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Application  = var.appname
  }
}

resource "aws_subnet" "default_subnet" {
  for_each = var.subnet_numbers

  vpc_id            = aws_vpc.default_vpc.id
  availability_zone = each.value
  cidr_block        = cidrsubnet(aws_vpc.default_vpc.cidr_block, 8, index(var.subnet_numbers, each.value) + 1)
  tags = {
    Application  = var.appname
  }
}
