resource "aws_api_gateway_vpc_link" "apigw" {
  name        = local.apigw_name
  description = "allows public API Gateway for ${local.apigw_name} to talk to private NLB"
  target_arns = [module.nlb.lb_arn]

  tags = { Name = local.apigw_name }

}

## API Gateway cloud watch logs
resource "aws_api_gateway_account" "main" {
  cloudwatch_role_arn = aws_iam_role.apigw.arn
}

resource "aws_iam_role" "apigw" {
  name = "api_gateway_cloudwatch_global"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "default"
  role = aws_iam_role.apigw.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

data "aws_iam_policy" "s3_readonly_access" {
  name = "AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "s3_policy_attach" {
  role       = aws_iam_role.apigw.name
  policy_arn = data.aws_iam_policy.s3_readonly_access.arn
}