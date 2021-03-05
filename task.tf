locals {
  ports = [for p in var.ports: {
            "containerPort": p[0],
            "hostPort": p[0],
            "protocol": p[1]
            }]

  envs = [for name,env in var.container.environment: {
                "name": name,
                "value": env
            }]
}

resource "aws_ecs_task_definition" "app-task" {
  family                   = "${var.appname}-server" # Naming our first task
  container_definitions    = templatefile("${path.module}/docker.tpl", {
    ports = jsonencode(local.ports)
    envs = jsonencode(local.envs)
    image = var.container.image
    memory = var.container.memory
    cpu = var.container.cpu
    app = var.appname
  })
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