[
    {
      "name": "${app}",
      "image": "${image}",
      "essential": true,
      "portMappings": [
        %{ for port in ports ~}
            {
            "containerPort": port,
            "hostPort": port
            }
        %{ endfor ~}
      ],
      "memory": "${memory}",
      "cpu": "${cpu}",
      "environment": [
        %{ for name, env in envs ~}
            {
                "name": "${name}",
                "value": "${env}"
            }
        %{ endfor ~}
      ]
    }
  ]