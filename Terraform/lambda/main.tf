

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
  source_arn    = "${var.signup_form_api_execution_arn}/*/*/*"
}

resource "aws_lambda_event_source_mapping" "recieve_dynamodb_events" {
  event_source_arn  = var.users_table_stream_arn
  function_name     = aws_lambda_function.account_creation.function_name
  starting_position = "LATEST"
}


// sign up lambda deployment 

data "archive_file" "lambda_zip_file_int" {
  type        = "zip"
  output_path = "/tmp/lambda_zip_file_int.zip"
  source {
    content  = file("lambda_src/sign_up_lambda_func.py")
    filename = "sign_up_lambda_func.py"
  }
}

resource "aws_lambda_function" "signup_validation" {
  filename         = data.archive_file.lambda_zip_file_int.output_path
  function_name    = "SIGN_UP_HANDLER"
  role             = var.signup_validation_role_arn
  handler          = "sign_up_lambda_func.lambda_handler"
  runtime          = "python2.7"
  timeout          = 60
  source_code_hash = data.archive_file.lambda_zip_file_int.output_base64sha256
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.signup_validation.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.account}:${var.aws_api_gateway_rest_api_id}/*/${var.aws_api_gateway_method_http_method}/User"
}
