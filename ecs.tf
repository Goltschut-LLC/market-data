resource "aws_ecr_repository" "main_ecr" {
  name = "main"
}

resource "aws_ecs_cluster" "main_ecs" {
  name = "main"
}

resource "aws_ecs_service" "main_ecs_service" {
  name            = "main"
  task_definition = aws_ecs_task_definition.main_ecs_task.arn
  cluster         = aws_ecs_cluster.main_ecs.id
  launch_type     = "FARGATE"

  desired_count = var.ecs_service_desired_count

  load_balancer {
    target_group_arn = aws_lb_target_group.main_alb_target_group.arn
    container_name   = "main"
    container_port   = "3000"
  }

  network_configuration {
    assign_public_ip = false

    security_groups = [
      aws_security_group.egress_all.id,
      aws_security_group.ingress_app.id,
    ]

    subnets = aws_subnet.private_subnets.*.id
  }
}

resource "aws_ecs_task_definition" "main_ecs_task" {
  family                   = "main"
  execution_role_arn       = aws_iam_role.ecs_role.arn
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  container_definitions = <<EOF
  [
    {
      "name": "main",
      "image": "${aws_ecr_repository.main_ecr.repository_url}:latest",
      "portMappings": [{ "containerPort": 3000  }],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region": "${data.aws_region.current.name}",
          "awslogs-group": "/ecs/main",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
EOF

}
