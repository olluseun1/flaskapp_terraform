# # #creating ECS cluster

resource "aws_ecs_cluster" "flaskapp_cluster" {
  name = "flaskapp"
}

resource "aws_ecs_task_definition" "flaskapp_definition" {
  family                   = "flaskapp"
  container_definitions = <<DEFINITION
  [
    {
        "name": "flaskapp",
        "image": "${aws_ecr_repository.ecs_repo.repository_url}",
        "essential": true,
        "portMappings": [
            {
                "containerPort": 3000,
                "hostPort": 3000
            }
        ],
        "memory": 512,
        "cpu": 256,
        "networkMode": "awsvpc"
    }
  ]
  DEFINITION
  requires_compatibilities = ["EC2"]
  network_mode = "bridge"
  memory = 512
  cpu = 256
  execution_role_arn = "${aws_iam_role.ecsTaskExecutionRole.arn}"
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
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
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_instance_profile" "ecs-agent" {
    name = "ecs-agent"
    role = aws_iam_role.ecsTaskExecutionRole.name
  
}

# #ECS Service

resource "aws_ecs_service" "ecs_service" {
  name            = "flaskapp"
  cluster         = aws_ecs_cluster.flaskapp_cluster.id
  task_definition = aws_ecs_task_definition.flaskapp_definition.arn

  launch_type     = "EC2"


  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.id
    container_name   = aws_ecs_task_definition.flaskapp_definition.family
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.flaskapp_listener]
}

