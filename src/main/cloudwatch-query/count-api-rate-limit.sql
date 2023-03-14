fields @timestamp, @message
| parse @message /Plan ID (?<plan>[^,\.]+)[,\.]/
| filter @message like 'exceeded throttle limit'
| stats count(*) as Tot by plan