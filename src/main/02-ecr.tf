resource "aws_ecr_repository" "ecr" {
  name = format("%s-ecr", local.project, )

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = { "Name" : format("%s-ecr", local.project) }

}

resource "aws_ecr_lifecycle_policy" "ecr" {
  repository = aws_ecr_repository.ecr.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keeps last 10 images"
      action = {
        type = "expire"
      }
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
    }]
  })
}