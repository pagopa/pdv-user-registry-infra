# Overview Personal Data Vault

## Summary

PagoPa Spa has to manage user data, potentially from all Italian citizens who interact with digital services in Public Administrations.
Often this data is highly confidential and has to be compliant with regulations.

Personal Data Vault is a service provided by PagaPa aiming to manage in a compliant manner Person Identifiable Information and tokenize it with pseudo random code.

We classify this service tier zero with the meaning that other services rely on it and it provides a set of Rest Api to interact with it.
Cloud Infrastructure

The application consists of just a couple of micro services - java spring boot applications - and it’s hosted in AWS with the goal to be:
Highly available
Scale fast to support high number of requests with burst estimated till 1250 req / sec
Secure due to the fact it’s managing confidential information.

The main resources hosting the solution in the diagram below are:
Api Gateway with regional endpoint, WAF and no caching by requirements.
Network Load Balancer (NLB) deployed in 3 private subnets
VPC Link to allow the communication between the Api Gateway and the NLB
ECS Fargate Cluster with tasks running in 2 / 3 private subnets and autoscaling based on CPU metrics
DynamoDB table with autoscaling
[Descoped]Cloud HSM to provide a customer managed key to encrypt / decrypt data in DynamoDB 

Note: Rest Api(s) which are publicly available require the standard Api Gateway x-api-key http header to authenticate and each key is associated to a dedicated plan with Rate Limits per method.
