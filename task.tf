
resource "aws_ecs_task_definition" "app-task" {
  family                   = "${var.appname}-container"
  container_definitions    = jsonencode([{
      name= var.appname
      image= var.container.image
      essential= true
      portMappings= [for p in var.ports: {
            "containerPort": p[0],
            "hostPort": p[0],
            "protocol": p[1]
            }]
      memory= var.container.memory
      cpu= var.container.cpu
      environment= [for name, env in var.container.environment: {
                "name": name,
                "value": env
            }]
    }])
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = var.container.memory         # Specifying the memory our container requires
  cpu                      = var.container.cpu            # Specifying the CPU our container requires
  execution_role_arn       = data.aws_iam_role.ecsTaskExecutionRole.arn

  dynamic "volume" {
      for_each = var.container.volumes

      content {
        name = volume.key

        efs_volume_configuration {
          file_system_id          = aws_efs_file_system.app-fs.id
          root_directory          = volume.value.host_path
        }
    }
  }

  tags = {
    Application  = var.appname
  }
}

data "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
}