resource "aws_ecs_service" "ecs-service" {
   platform_version = "1.4.0"
  name            = "${var.appname}-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.app-task.arn
  launch_type     = "FARGATE"
  desired_count   = 1 # only one docker supported

   network_configuration {
    subnets          = concat([for o in aws_subnet.internal_subnets : o.id], [for o in aws_subnet.external_subnets : o.id])
  }

  dynamic "load_balancer" {
    for_each= var.ports
    content{ 
        target_group_arn = aws_lb_target_group.target_group[load_balancer.key].arn # Referencing our target group
        container_name   = var.appname
        container_port   = load_balancer.value[0]

    }
  }

   tags = {
    Application  = var.appname
  }

  depends_on = [ aws_internet_gateway.gw, aws_ecs_task_definition.app-task, aws_lb_target_group.target_group, aws_lb_listener.listener ]
}