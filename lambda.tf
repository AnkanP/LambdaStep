data "aws_iam_policy_document" "lambda_trust_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]

    }

  }
}


resource "aws_iam_role" "lambda_iam_role" {
  name               = "local-${var.lambda_function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust_policy.json

}



module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = var.lambda_function_name
  description   = "My awesome lambda function"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.11"

  create                            = true
  create_role                       = false ## May be need explicit role creation with prefix local
  create_package                    = true
  create_function                   = true
  lambda_role                       = aws_iam_role.lambda_iam_role.arn
  use_existing_cloudwatch_log_group = false
  reserved_concurrent_executions    = -1

  # package
  artifacts_dir = "artifacts"
  source_path   = "src/lambda/"

  tags       = var.tags
  depends_on = [aws_iam_role.lambda_iam_role]
}



module "lambda_function_rds" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = var.lambda_function_name_rds
  description   = "My awesome lambda function"
  handler       = "lambda-rds.lambda_handler"
  runtime       = "python3.11"

  create                            = true
  create_role                       = false ## May be need explicit role creation with prefix local
  create_package                    = true
  create_function                   = true
  lambda_role                       = aws_iam_role.lambda_iam_role.arn
  use_existing_cloudwatch_log_group = false
  reserved_concurrent_executions    = -1

  # package
  artifacts_dir = "artifacts"
  source_path   = "src/lambda-rds/"

  tags       = var.tags
  depends_on = [aws_iam_role.lambda_iam_role]
}





resource "aws_lambda_permission" "s3_permission_to_trigger_lambda" {
  statement_id  = "AllowLambdaExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.lambda_function_arn
  principal     = "s3.amazonaws.com"
  source_arn    = module.s3_bucket.s3_bucket_arn


}


# permission for lambda to access other services

data "aws_iam_policy_document" "lambda_role_policy_document" {
  statement {
    sid    = "AllowLambdaInvokeLambda"
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction"
    ]

    #resources = module.lambda_function.lambda_function_arn
    resources = ["*"]
  }

  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"
    actions = ["logs:PutLogEvents",
      "logs:CreateLogStream",
    "logs:CreateLogGroup"]
    #resources = module.lambda_function.arn
    resources = ["${module.lambda_function.lambda_cloudwatch_log_group_arn}:*:*",
      "${module.lambda_function.lambda_cloudwatch_log_group_arn}:*"
    ]

  }

  statement {
    sid       = "AllowS3Access"
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }




}

resource "aws_iam_policy" "lambda_role_policy" {
  name   = "local-${var.lambda_function_name}-policy"
  policy = data.aws_iam_policy_document.lambda_role_policy_document.json
  path   = "/"

}
resource "aws_iam_role_policy_attachment" "lambda_iam_role_attachment" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.lambda_role_policy.arn
  depends_on = [aws_iam_role.lambda_iam_role]

}