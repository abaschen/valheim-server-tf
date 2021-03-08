
resource aws_cloudwatch_log_group "app-container"{
  name = "${var.appname}-logs"
  retention_in_days = 1
  tags = {
    Application  = var.appname
  }
}
resource "aws_ecs_task_definition" "app-task" {
  family                   = "${var.appname}-container"
  container_definitions    = jsonencode([{
      name= var.appname
      image= var.container.image
      essential= true
      portMappings= [for p in var.ports: {
          containerPort= p[0]
          hostPort= p[0]
          protocol= p[1]
        }]
      logConfiguration = {
       logDriver= "awslogs"
       options= {
          awslogs-group= aws_cloudwatch_log_group.app-container.name
          awslogs-region= var.region
          awslogs-stream-prefix= var.appname
        }
      }
      mountPoints = [for name, vol in var.container.volumes: {
          containerPath= vol.host_path
          sourceVolume= "${name}-efs"
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
  execution_role_arn       = data.aws_iam_role.taskExecutionRole.arn

  dynamic "volume" {
      for_each = var.container.volumes

      content {
        name = "${volume.key}-efs"

        efs_volume_configuration {
          file_system_id          = aws_efs_file_system.app-fs.id
          root_directory = "/${volume.key}"
        }
    }
  }

  tags = {
    Application  = var.appname
  }
}

data "aws_iam_role" "taskExecutionRole" {
  name               = "ecsTaskExecutionRole"
}