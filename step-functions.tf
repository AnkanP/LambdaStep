data "aws_iam_policy_document" "state_machine_trust_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]

    }

  }
}

resource "aws_iam_role" "state_machine_iam_role" {
  name               = "local-${var.step_function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.state_machine_trust_policy.json

}


module "step_function" {
  source = "terraform-aws-modules/step-functions/aws"

  name                              = var.step_function_name
  create                            = true
  create_role                       = false
  use_existing_role                 = true
  role_arn                          = aws_iam_role.state_machine_iam_role.arn
  use_existing_cloudwatch_log_group = false
  cloudwatch_log_group_name         = var.step_function_name

  type = "STANDARD"
  logging_configuration = {
    "level"                  = "ALL",
    "include_execution_data" = true
  }




  definition = file("src/step-function/invokelambda.asl.json")
  # service integration not required. explict policies created
  tags       = var.tags
  depends_on = [aws_iam_role.state_machine_iam_role]
}


# state,machine need to be created first
# permission for state machine to invoke lambda & cloudwatchlogs

data "aws_iam_policy_document" "state_machine_role_policy_document" {
  statement {
    sid    = "AllowStateMachineLambdaInvoke"
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction"
    ]

    resources = ["*"]
    #resources = ["${module.lambda_function.lambda_function_arn}:*"]
  }

  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"
    actions = ["logs:CreateLogDelivery",
      "logs:CreateLogStream",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutLogEvents",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
    "logs:DescribeLogGroups"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowAthenaAccess"
    effect = "Allow"
    actions = ["athena:*",
      "s3:*",
      "glue:*"
    ]
    resources = ["*"]
  }



}

resource "aws_iam_policy" "state_machine_role_policy" {
  name   = "local-${var.step_function_name}-policy"
  policy = data.aws_iam_policy_document.state_machine_role_policy_document.json
  path   = "/"

}
resource "aws_iam_role_policy_attachment" "state_machine_iam_role_attachment" {
  role       = aws_iam_role.state_machine_iam_role.name
  policy_arn = aws_iam_policy.state_machine_role_policy.arn
  depends_on = [aws_iam_role.state_machine_iam_role]

}