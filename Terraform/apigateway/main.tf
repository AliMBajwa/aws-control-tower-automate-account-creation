resource "aws_api_gateway_rest_api" "sign_up_api" {
  name        = "Sign Up API"
  description = "A sign_up enabled API that handles user data"
}
resource "aws_api_gateway_resource" "sign_up_resource" {
  path_part   = "User"
  parent_id   = aws_api_gateway_rest_api.sign_up_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.sign_up_api.id
}
resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = aws_api_gateway_rest_api.sign_up_api.id
  resource_id   = aws_api_gateway_resource.sign_up_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.sign_up_api.id
  resource_id = aws_api_gateway_resource.sign_up_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = ["aws_api_gateway_method.options_method"]
}
resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id          = aws_api_gateway_rest_api.sign_up_api.id
  resource_id          = aws_api_gateway_resource.sign_up_resource.id
  http_method          = aws_api_gateway_method.options_method.http_method
  type                 = "MOCK"
  depends_on           = ["aws_api_gateway_method.options_method"]
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" = "{ 'statusCode': 200 }"
  }
}
resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.sign_up_api.id
  resource_id = aws_api_gateway_resource.sign_up_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = ["aws_api_gateway_method_response.options_200"]
}

resource "aws_api_gateway_method" "sign_up_method" {
  rest_api_id   = aws_api_gateway_rest_api.sign_up_api.id
  resource_id   = aws_api_gateway_resource.sign_up_resource.id
  http_method   = "POST"
  authorization = "NONE"
}
resource "aws_api_gateway_method_response" "sign_up_method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.sign_up_api.id
  resource_id = aws_api_gateway_resource.sign_up_resource.id
  http_method = aws_api_gateway_method.sign_up_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  depends_on = ["aws_api_gateway_method.sign_up_method"]
}
resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.sign_up_api.id
  resource_id             = aws_api_gateway_resource.sign_up_resource.id
  http_method             = aws_api_gateway_method.sign_up_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.aws_lambda_function_arn}/invocations"
}
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = var.aws_api_gateway_rest_api_id
  stage_name  = "Dev"
  depends_on  = ["aws_api_gateway_integration.integration"]
}
