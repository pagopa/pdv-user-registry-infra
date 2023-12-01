locals {
  repositories = [
    format("%s-person", local.project, ),
    format("%s-user-registry", local.project, ),
    format("%s-x-ray-daemon-ecr", local.project, ),
  ]
}

resource "aws_ecr_repository" "main" {
  count = length(local.repositories)
  name  = local.repositories[count.index]

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = { "Name" : local.repositories[count.index] }

}

resource "aws_ecr_lifecycle_policy" "main" {
  count      = length(local.repositories)
  repository = aws_ecr_repository.main[count.index].name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = format("Keeps last %s images", var.ecr_keep_nr_images)
      action = {
        type = "expire"
      }
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = var.ecr_keep_nr_images
      }
    }]
  })
}

resource "null_resource" "docker_packaging" {
  count = var.publish_x-ray_image ? 1 : 0

  provisioner "local-exec" {
    command = <<EOF
	    aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com
	    docker pull ${var.x_ray_daemon_image_uri}@${var.x_ray_daemon_image_sha} --platform=linux/amd64
        docker tag ${var.x_ray_daemon_image_uri}@${var.x_ray_daemon_image_sha} ${aws_ecr_repository.main[2].repository_url}:${var.x_ray_daemon_image_version}
	    docker push ${aws_ecr_repository.main[2].repository_url}:${var.x_ray_daemon_image_version}
	    EOF
  }

  triggers = {
    "run_at" = timestamp()
  }

  depends_on = [
    aws_ecr_repository.main,
  ]
}