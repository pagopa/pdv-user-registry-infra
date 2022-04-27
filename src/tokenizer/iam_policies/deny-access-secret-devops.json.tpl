{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DenySccessDevOpsSecrets",
            "Effect": "Deny",
            "Action": "secretsmanager:*",
            "Resource": "${secret_arn}"
        }
    ]
}