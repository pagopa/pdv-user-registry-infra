fields @timestamp, @message
| parse @message "Plan ID *." as plan
| filter @message like 'exceeded throttle limit'
| sort @timestamp desc
| limit 20