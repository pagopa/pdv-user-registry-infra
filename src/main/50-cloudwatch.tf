# ApiGw throttling
resource "aws_cloudwatch_query_definition" "apigw_429" {
  name = "ApiGateway/429"

  log_group_names = [
    local.user_registry_log_group_name
  ]
  query_string = file("./cloudwatch-query/apigw-429.sql")
}

resource "aws_cloudwatch_query_definition" "apigw_count_rate_limit" {
  name = "ApiGateway/Count Rate Limit"

  log_group_names = [
    local.user_registry_log_group_name
  ]
  query_string = file("./cloudwatch-query/count-api-rate-limit.sql")
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

resource "aws_cloudwatch_query_definition" "ecs_provisioned_throughput_exception" {
  name = "ECS/Count Provisioned Throughput"

  log_group_names = [
    aws_cloudwatch_log_group.ecs_person.name,
    aws_cloudwatch_log_group.ecs_user_registry.name,
  ]
  query_string = file("./cloudwatch-query/count-provisioned-throughput-exceeded.sql")
}

resource "aws_cloudwatch_query_definition" "ecs_log_by_traceid" {
  name = "ECS/Log by traceid"

  log_group_names = [
    aws_cloudwatch_log_group.ecs_tokenizer.name,
  ]
  query_string = file("./cloudwatch-query/log-by-traceid.sql")
}