locals {
  prefix = var.prefix
}

variable "prefix" {
  type = string
}

variable "dynamodb_table" {
  type = string
}

variable "region" {
  type = string
}

variable "account" {
  type = string
}

variable "signup_validation_lambda_function_arn" {
  type = string
}

variable "aws_api_gateway_rest_api_id" {
  type = string
}

variable "aws_api_gateway_method_http_method" {
  type = string
}