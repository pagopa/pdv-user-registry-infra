resource "aws_cloudwatch_query_definition" "apigw_429" {
  name = "ApiGateway/429"

  log_group_names = [
    local.user_registry_log_group_name
  ]
  query_string = file("./cloudwatch-query/apigw-429.sql")
}

resource "aws_cloudwatch_query_definition" "ecs_log_level_error" {
  name = "ECS/Errors"

  log_group_names = [
    aws_cloudwatch_log_group.ecs_person.name,
    aws_cloudwatch_log_group.ecs_user_registry.name,
  ]
  query_string = file("./cloudwatch-query/log-level-error.sql")
}

resource "aws_cloudwatch_query_definition" "ecs_exception" {
  name = "ECS/Exceptions"

  log_group_names = [
    aws_cloudwatch_log_group.ecs_person.name,
    aws_cloudwatch_log_group.ecs_user_registry.name,
  ]
  query_string = file("./cloudwatch-query/log-with-exception.sql")
}