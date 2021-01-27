terraform {
  backend "s3" {
    bucket = "aws-cis-pe-accounts-terraform-state"
    key    = "aws_cis_pe_training_accounts.tfstate"
    region = "eu-west-2"
  }
}

#Project Maykr.

provider "aws" {
  region = "eu-west-2"
}

module "apigateway" {
  source                      = "./apigateway"
  prefix                      = local.prefix
  region                      = var.region
  aws_lambda_function_arn     = module.lambda.signup_validation_lambda_function_arn
  aws_api_gateway_rest_api_id = module.apigateway.aws_api_gateway_rest_api_id
}

module "cloudwatch" {
  source = "./cloudwatch"
  prefix = local.prefix
}

module "iam" {
  source                             = "./iam"
  prefix                             = local.prefix
  dynamodb_table                     = module.storage.users_table_arn
  region                             = var.region
  account                            = var.account
  aws_api_gateway_rest_api_id        = module.apigateway.aws_api_gateway_rest_api_id
  aws_api_gateway_method_http_method = module.apigateway.aws_api_gateway_method_http_method
  signup_validation_lambda_function_arn            = module.lambda.signup_validation_lambda_function_arn
}

module "lambda" {
  source                     = "./lambda"
  prefix                     = local.prefix
  region                     = var.region
  account                    = var.account
  deployment_bucket          = module.storage.deployment_bucket
  signup_validation_role_arn = module.iam.signup_validation_role_arn
  account_creation_role_arn  = module.iam.account_creation_role_arn
  signup_api_execution_arn   = module.apigateway.signup_api_execution_arn
  users_table_stream_arn     = module.storage.users_table_stream_arn
  dynamodb_table_name        = module.storage.dynamodb_table_name
  aws_api_gateway_rest_api_id = module.apigateway.aws_api_gateway_rest_api_id
  aws_api_gateway_method_http_method = module.apigateway.aws_api_gateway_method_http_method
}

module "storage" {
  source       = "./storage"
  prefix       = local.prefix
  billing_mode = var.billing_mode
}
