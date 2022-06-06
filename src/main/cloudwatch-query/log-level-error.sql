fields @timestamp, @message
| parse @message "+0000 * [" as loglevel
| filter loglevel in ["ERROR"]
| sort @timestamp desc
| limit 20