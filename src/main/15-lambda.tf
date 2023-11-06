resource "aws_lambda_function" "check_delete_item" {
  function_name    = "check-delete-item"
  handler          = "function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.python_lambda_package.output_base64sha256
  filename         = "${path.module}/../lambda/test/function.zip"

  role = aws_iam_role.lambda_check_delete_item_execution_role.arn
}

data "archive_file" "python_lambda_package" {
  type        = "zip"
  source_file = "${path.module}/../lambda/test/function.py"
  output_path = "${path.module}/../lambda/test/function.zip"
}

resource "aws_iam_role" "lambda_check_delete_item_execution_role" {
  name = "CheckDeleteItesmExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "lambda_execution_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    actions = [
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:DescribeStream",
      "dynamodb:ListStreams"
    ]

    resources = [aws_dynamodb_table.test.stream_arn]
  }
}

resource "aws_iam_policy" "lambda_execution_policy" {
  name        = "lambda-execution-policy"
  description = "Policy for Lambda execution role"
  policy      = data.aws_iam_policy_document.lambda_execution_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
  role       = aws_iam_role.lambda_check_delete_item_execution_role.name
}


resource "aws_dynamodb_table" "test" {
  name         = "Test"
  billing_mode = "PAY_PER_REQUEST" # Or "PROVISIONED" if you prefer provisioned throughput
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
  # Add more attributes as needed

  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"
}


resource "aws_lambda_permission" "allow_dynamodb_trigger" {
  statement_id  = "AllowExecutionFromDynamoDB"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.check_delete_item.function_name
  principal     = "dynamodb.amazonaws.com"
  source_arn    = aws_dynamodb_table.test.arn
}

resource "aws_lambda_event_source_mapping" "dynamodb_event" {
  event_source_arn  = aws_dynamodb_table.test.stream_arn
  function_name     = aws_lambda_function.check_delete_item.arn
  batch_size        = 10
  starting_position = "LATEST"
  enabled           = true

  filter_criteria {
    filter {
      pattern = jsonencode(
        {
          eventName = [
            "REMOVE",
            "MODIFY",
          ]
      })
    }
  }
}
