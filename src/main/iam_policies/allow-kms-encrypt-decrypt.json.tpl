{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowEncryptDecrypt",
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:Encrypt"
            ],
            "Resource": "arn:aws:kms:*:${account_id}:key/*"
        }
    ]
}