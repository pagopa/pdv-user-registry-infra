{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ECSDeploy",
            "Effect": "Allow",
            "Action": [
                "ecs:UpdateService",
                "ecr:DescribeImages",
                "ecr:TagResource",
                "ecr:ListImages",
                "ecr:GetAuthorizationToken",
                "ecr:PutImage"
            ],
            "Resource": [
                "arn:aws:ecs:*:${account_id}:service/*/*",
                "arn:aws:ecr:*:${account_id}:repository/*"
            ]
        }
    ]
}