

resource "aws_lambda_function" "account_creation" {
  function_name     = "${var.prefix}_account_creation"
  description       = "The lambda function which will create accounts from details in a DynamoDb table."
  s3_bucket         = var.deployment_bucket
  s3_key            = "account_creation.zip"
  s3_object_version = "LATEST"
  role              = var.account_creation_role_arn
  handler           = "account_creation.lambda_handler"
  runtime           = "python3.8"

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
    }
  }
}

resource "aws_lambda_permission" "invoke_account_creation" {
  statement_id  = "AllowDynamoDbtoInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.account_creation.function_name
  principal     = "dynamodb.amazonaws.com"
  source_arn    = aws_lambda_function.account_creation.arn
}
resource "aws_lambda_permission" "invoke_signup_validation" {
  statement_id  = "AllowSignupAPItoInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.signup_validation.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.signup_api_execution_arn}/*/*/*"
}

resource "aws_lambda_event_source_mapping" "recieve_dynamodb_events" {
  event_source_arn  = var.users_table_stream_arn
  function_name     = aws_lambda_function.account_creation.function_name
  starting_position = "LATEST"
}


// sign up lambda deployment 

resource "aws_lambda_function" "signup_validation" {
  function_name     = "${var.prefix}_signup_validation"
  description       = "The lambda function which will validate events from API Gateway and create new users in DynamoDb account."
  s3_bucket         = var.deployment_bucket
  s3_key            = "signup_validator.zip"
  s3_object_version = "LATEST"
  role              = var.signup_validation_role_arn
  handler           = "signup_validator.lambda_handler"
  runtime           = "python3.8"

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
    }
  }
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.signup_validation.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.account}:${var.aws_api_gateway_rest_api_id}/*/${var.aws_api_gateway_method_http_method}/User"
}
