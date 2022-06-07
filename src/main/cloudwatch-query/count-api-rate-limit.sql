fields @timestamp, @message
| parse @message "Plan ID *," as plan
| filter @message like 'exceeded throttle limit'
| limit 20
| stats count(*) as Tot by plan