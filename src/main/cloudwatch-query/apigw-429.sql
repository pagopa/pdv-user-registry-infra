fields @timestamp, @message
| filter @message like 'Method completed with status: 429'
| sort @timestamp desc
| limit 20