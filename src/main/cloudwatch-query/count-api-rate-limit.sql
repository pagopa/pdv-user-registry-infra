fields @timestamp, @message
| filter @message like 'exceeded throttle limit'
| stats count(*)