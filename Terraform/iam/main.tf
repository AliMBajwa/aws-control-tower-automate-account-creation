#Roles

resource "aws_iam_role" "signup_validation_role" {
  name = "${var.prefix}_signup_validation_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role" "account_creation_role" {
  name = "${var.prefix}_account_creation_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json

}

#Custom Policies

resource "aws_iam_policy" "signup_validation_policy" {
  name = "signup_validation_role_policy"
  policy = data.aws_iam_policy_document.signup_validation_role_policy_doc.json
}
  

resource "aws_iam_policy" "account_creation_policy" {
  name = "${var.prefix}_account_creation_policy"
  policy = data.aws_iam_policy_document.account_creation_role_policy_doc.json
}

#Role Policy Attachments

resource "aws_iam_role_policy_attachment" "signup_validation_role_policy_attachment_main" {

  role = aws_iam_role.signup_validation_role.name
  policy_arn = aws_iam_policy.signup_validation_policy.arn
}

resource "aws_iam_role_policy_attachment" "signup_validation_role_policy_attachment_AWSLambdaBasicExecutionRole" {
  role = "AWSLambdaBasicExecutionRole"
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}

resource "aws_iam_role_policy_attachment" "account_creation_role_policy_attachment_main" {

  role = aws_iam_role.account_creation_role.name
  policy_arn = aws_iam_policy.signup_validation_policy.arn
}

resource "aws_iam_role_policy_attachment" "account_creation_role_policy_attachment_AWSLambdaBasicExecutionRole" {
  role = "AWSLambdaBasicExecutionRole"
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}
