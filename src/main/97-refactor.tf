move {
  from = aws_api_gateway_api_key.main["INTEROP-DEV"]
  to   = aws_api_gateway_api_key.additional["INTEROP-DEV"]
}

move {
  from = aws_api_gateway_api_key.main["INTEROP-UAT"]
  to   = aws_api_gateway_api_key.additional["INTEROP-UAT"]
}

move {
  from = aws_api_gateway_api_key.main["INTEROP"]
  to   = aws_api_gateway_api_key.additional["INTEROP"]
}