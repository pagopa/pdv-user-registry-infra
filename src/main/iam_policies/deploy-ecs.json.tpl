{
    "Statement": [
        {
            "Action": [
                "ecr:DescribeImages",
                "ecr:ListImages",
                "ecr:TagResource",
                "ecr:GetAuthorizationToken",
                "ecr:PutImage",
                "ecs:DescribeServices",
                "ecs:UpdateService"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:ecs:*:${account_id}:service/*",
                "arn:aws:ecr:*:${account_id}:repository/*"
            ],
            "Sid": "ECSDeploy"
        },
        {
            "Action": [
                "ecs:DescribeTaskDefinition",
                "ecs:RegisterTaskDefinition"
            ],
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "ECSTaskDefinition"
        },
        {
            "Action": "iam:PassRole",
            "Effect": "Allow",
            "Resource": "${execute_task_role_arn}",
            "Sid": "PassRole"
        }
    ],
    "Version": "2012-10-17"
}