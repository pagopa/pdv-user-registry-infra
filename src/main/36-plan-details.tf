
# Lambda module configuration
module "lambda_usage_plan_details" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "6.8.0"

  function_name           = "usage-plan-details"
  description             = "API to retrieve usage plan api keys details"
  handler                 = "index.lambda_handler"
  runtime                 = "python3.10"
  ignore_source_code_hash = true

  create_package         = false
  local_existing_package = "../lambda/hello-python/lambda.zip"

  # Environment variables if needed
  cloudwatch_logs_retention_in_days = 14
  environment_variables = {
    LOG_LEVEL   = "INFO"
    REST_API_ID = aws_api_gateway_rest_api.user_registry.id
  }

  timeout = 30

  # Attach policies
  attach_policy_statements = true
  policy_statements = {
    apigateway = {
      effect = "Allow"
      actions = [
        "apigateway:GET",
      ]
      resources = [
        "arn:aws:apigateway:${var.aws_region}::/apikeys",
        "arn:aws:apigateway:${var.aws_region}::/apikeys/*",
        "arn:aws:apigateway:${var.aws_region}::/usageplans",
        "arn:aws:apigateway:${var.aws_region}::/usageplans/*"
      ]
    }
  }

  # lambda powertools layer
  layers = [
    "arn:aws:lambda:${var.aws_region}:017000801446:layer:AWSLambdaPowertoolsPythonV3-python312-x86_64:11"
  ]

}


# Role to deploy the lambda functions with github actions

locals {
  assume_role_plan_details_policy_github = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.id}:oidc-provider/token.actions.githubusercontent.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" : [
              "repo:pagopa/pdv-lambda-expose-usage-plan-details:environment:dev",
              "repo:pagopa/pdv-lambda-expose-usage-plan-details:environment:uat",
              "repo:pagopa/pdv-lambda-expose-usage-plan-details:environment:prod",
              "repo:pagopa/pdv-lambda-expose-usage-plan-details:ref:refs/heads/main"
            ]
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "deploy_lambda_usage_plan_details" {
  name        = "DeployLambda"
  description = "Policy to deploy Lambda functions"

  policy = jsonencode({

    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:CreateFunction",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "github_lambda_usage_plan_details_deploy" {
  name               = "GitHubLambdaUsagePlanDetailsDeploy"
  description        = "Role to deploy lambda functions with github actions."
  assume_role_policy = local.assume_role_plan_details_policy_github
}


resource "aws_iam_role_policy_attachment" "github_lambda_usage_plan_details_deploy" {
  role       = aws_iam_role.github_lambda_usage_plan_details_deploy.name
  policy_arn = aws_iam_policy.deploy_lambda_usage_plan_details.arn
}