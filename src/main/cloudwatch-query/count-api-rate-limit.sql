fields @timestamp, @message
| parse @message "Plan ID *," as plan
| filter @message like 'exceeded throttle limit'
| stats count(*) as Tot by plan