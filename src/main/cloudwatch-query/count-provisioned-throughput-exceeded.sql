fields @timestamp, @message
| filter @message like /ProvisionedThroughputExceededException/
| sort @timestamp desc