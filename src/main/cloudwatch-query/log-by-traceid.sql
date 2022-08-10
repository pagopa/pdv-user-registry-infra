fields @timestamp, @message
| parse @message /(?<timestamp>\d{4}\-\d{2}\-\d{2}T\d{2}\:\d{2}\:\d{2}\.\d{3}(\+|\-)\d{4})\s+(?<level>\w+)\s+\[(?<appName>[\w\-]+)\,(?<traceId>[\w\-]+)\,(?<spanId>[\w\-]+)\]\s+(?<pid>\d+)\s+\-\-\-\s+\[(?<thread>[\w\-]+)\]\s+(?<logger>[\w\-\.]+)\s+\:\s+(?<message>.*)/
| filter level = "DEBUG"
| filter traceId = "<here the traceid>"
| sort timestamp desc
| limit 50