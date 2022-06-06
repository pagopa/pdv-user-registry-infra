fields @timestamp, @message
| filter @message like /Exception/
| sort @timestamp desc