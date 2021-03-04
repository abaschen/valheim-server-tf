locals {
  template = jsonencode(templatefile("${path.module}/docker.tpl", {
    ports = var.ports[*].0
    envs = var.container.environment
    image = var.container.image
    memory = var.container.memory
    cpu = var.container.cpu
  }))
}

resource "aws_ecs_task_definition" "valheim-task" {
  family                   = "valheim-server" # Naming our first task
  container_definitions    = template
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = var.container.memory         # Specifying the memory our container requires
  cpu                      = var.container.cpu            # Specifying the CPU our container requires
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

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

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = {
    Application  = var.appname
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

}