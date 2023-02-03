{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ECSDeploy",
            "Effect": "Allow",
            "Action": [
                "iam:PassRole",
                "ecr:DescribeImages",
                "ecr:ListImages",
                "ecr:TagResource",
                "ecr:GetAuthorizationToken",
                "ecr:PutImage",
                "ecs:DescribeServices",
                "ecs:DescribeTaskDefinition",
                "ecs:RegisterTaskDefinition",
                "ecs:UpdateService"
            ],
            "Resource": [
                "arn:aws:ecs:*:${account_id}:service/*",
                "arn:aws:ecr:*:${account_id}:repository/*"
            ]
        }
    ]
}