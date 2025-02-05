fields @timestamp, @message
| parse @message /namespace=(?<plan>[\w-]+)]/
| filter @message like "feign.FeignException$NotFound: [404 ] during [GET]" and @message like "namespace="
| stats count(*) as Tot by plan
