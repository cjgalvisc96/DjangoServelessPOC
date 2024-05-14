resource "aws_apigatewayv2_api" "tracetech_traces_api_gateway_v2" {
  name          = "${var.env}_tracetech_traces_api_gateway_v2"
  protocol_type = "HTTP"

  tags = {
    Name    = "${var.env}_tracetech_traces_api_gateway_v2"
  }
}

resource "aws_cloudwatch_log_group" "tracetech_traces_aws_cloudwatch_log_group" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.tracetech_traces_api_gateway_v2.name}"
  retention_in_days = var.aws_cloudwatch_log_group__retention_in_days

  tags = {
    Name    = "${var.env}_tracetech_traces_aws_cloudwatch_log_group"
  }
}

resource "aws_apigatewayv2_stage" "tracetech_traces_api_gateway_stage_v2" {
  api_id      = aws_apigatewayv2_api.tracetech_traces_api_gateway_v2.id
  name        = var.env
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.tracetech_traces_aws_cloudwatch_log_group.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }

  tags = {
    Name    = "${var.env}_tracetech_traces_api_gateway_stage_v2"
  }
}


resource "aws_apigatewayv2_integration" "tracetech_traces_api_gateway_integration_v2" {
  api_id = aws_apigatewayv2_api.tracetech_traces_api_gateway_v2.id

  integration_method = "POST"
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.tracetech_traces_lambda_function.invoke_arn
}

resource "aws_apigatewayv2_route" "tracetech_traces_api_gateway_route_v2" {
  api_id = aws_apigatewayv2_api.tracetech_traces_api_gateway_v2.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.tracetech_traces_api_gateway_integration_v2.id}"
}
