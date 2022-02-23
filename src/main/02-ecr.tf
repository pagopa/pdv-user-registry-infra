resource "aws_ecr_repository" "ecr" {
  name = format("%s-%s-ecr", local.project, var.aws_region)

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = merge(
    { "Name" : format("ur-%s-ecr", var.aws_region) },
    var.tags,
  )
}