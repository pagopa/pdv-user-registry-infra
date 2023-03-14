fields @timestamp, @message
| parse @message /Plan ID (?<plan>[^,\.]+)[,\.]/
| filter @message like 'exceeded throttle limit'
| sort @timestamp desc
| limit 20