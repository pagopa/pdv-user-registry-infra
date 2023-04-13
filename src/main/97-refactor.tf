moved {
  from = aws_api_gateway_api_key.main["INTEROP-DEV"]
  to   = aws_api_gateway_api_key.additional["INTEROP-DEV"]
}

moved {
  from = aws_api_gateway_api_key.main["INTEROP-UAT"]
  to   = aws_api_gateway_api_key.additional["INTEROP-UAT"]
}

moved {
  from = aws_api_gateway_api_key.main["INTEROP"]
  to   = aws_api_gateway_api_key.additional["INTEROP"]
}