## ROLES
resource "aws_iam_policy" "tracetech_traces_lambda_iam_policy" {
  name   = "${var.env}_tracetech_traces_lambda_iam_policy"
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ec2:*",
            "rds:*",
            "logs:*"
          ]
          Resource = "*"
        },
      ]
    }
  )

  tags = {
    Name    = "${var.env}_tracetech_traces_lambda_iam_policy"
  }
}


resource "aws_iam_role" "tracetech_traces_lambda_iam_role" {
  name               = "${var.env}_tracetech_traces_lambda_iam_role"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "lambda.amazonaws.com"
          }
        },
      ]
    }
  )

  tags = {
    Name    = "${var.env}_tracetech_traces_lambda_iam_role"
  }
}

resource "aws_iam_role_policy_attachment" "tracetech_traces_iam_role_policy_attachment" {
  policy_arn = aws_iam_policy.tracetech_traces_lambda_iam_policy.arn
  role       = aws_iam_role.tracetech_traces_lambda_iam_role.name
}

## LAMBDA
resource "aws_lambda_layer_version" "tracetech_traces_lambda_layer_version" {
  filename            = "${var.tf_module_path}/environments/${var.env}/${var.env}_traces_lambda_layer_dependencies.zip"
  layer_name          = "${var.env}_tracetech_traces_lambda_layer_version"
  compatible_runtimes = var.aws_lambda_layer__compatible_runtimes
}

resource "aws_lambda_function" "tracetech_traces_lambda_function" {
  filename         = "${var.tf_module_path}/environments/${var.env}/${var.env}_traces_lambda_code.zip"
  source_code_hash = filebase64sha256("${var.tf_module_path}/environments/${var.env}/${var.env}_traces_lambda_code.zip")

  layers           = [var.tracetech_shared_lambda_layer_arn,aws_lambda_layer_version.tracetech_traces_lambda_layer_version.arn]
  function_name    = "${var.env}_tracetech_traces_lambda_function"
  role             = aws_iam_role.tracetech_traces_lambda_iam_role.arn
  handler          = "fastapi_api.main.lambda_handler"

  runtime          = var.aws_lambda_function__runtime
  timeout          = var.aws_lambda_function__timeout
  memory_size      = var.aws_lambda_function__memory_size

  vpc_config {
    subnet_ids         = [var.tracetech_subnet_id]
    security_group_ids = [var.tracetech_traces_lambda_security_group_id, var.tracetech_traces_rds_security_group_id]
  }

  tags = {
    Name = "${var.env}_tracetech_traces_lambda_function"
  }
}

## PERMISSIONS
resource "aws_lambda_permission" "tracetech_traces_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tracetech_traces_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.tracetech_traces_api_gateway_v2.execution_arn}/*/*"
}
