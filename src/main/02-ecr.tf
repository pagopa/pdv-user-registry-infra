resource "aws_ecr_repository" "ecr" {
  name = format("%s-ecr", local.project, )

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = { "Name" : format("%s-ecr", local.project) }

}