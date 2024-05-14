output "tracetech_traces_api_gateway_v2_url" {
  value = "https://${aws_apigatewayv2_api.tracetech_traces_api_gateway_v2.id}.execute-api.REGION.amazonaws.com/${aws_apigatewayv2_stage.tracetech_traces_api_gateway_stage_v2.name}/v1"
}