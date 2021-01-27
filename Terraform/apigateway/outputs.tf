output "signup_api_execution_arn" {
  value = aws_api_gateway_rest_api.sign_up_api.execution_arn
}

output "aws_api_gateway_rest_api_id" {
  value = aws_api_gateway_rest_api.sign_up_api.id
}

output "aws_api_gateway_method_http_method" {
  value = aws_api_gateway_method.sign_up_method.http_method
}
