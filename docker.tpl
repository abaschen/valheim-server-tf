[
    {
      "name": "${app}-server",
      "image": "${image}",
      "essential": true,
      "portMappings": ${ports},
      "memory": ${memory},
      "cpu": ${cpu},
      "environment": ${envs}
    }
  ]