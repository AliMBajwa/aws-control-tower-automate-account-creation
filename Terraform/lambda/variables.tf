variable "region"{
  type = string
}

variable "account"{
  type = string
}

variable "prefix" {
  type = string
}

variable "signup_validation_role_arn" {
  type = string
}

variable "account_creation_role_arn" {
  type = string
}

variable "deployment_bucket" {
  type = string
}

variable "users_table_stream_arn" {
  type = string
}

variable "signup_api_execution_arn" {
  type = string
}

variable "dynamodb_table_name" {
  type = string
}

variable "aws_api_gateway_rest_api_id"{
  type = string
}

variable "aws_api_gateway_method_http_method"{
  type = string
}

