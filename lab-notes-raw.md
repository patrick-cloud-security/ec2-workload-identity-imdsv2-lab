# EC2 Workload Identity / IMDSv2 Lab - Raw Notes

## Objective

Build a minimal AWS lab showing how an EC2 instance receives temporary role credentials through an instance profile and IMDSv2, then analyse the blast radius if those credentials are stolen.

## Phase 1 - IAM Role

Created an EC2 workload role with a trust policy allowing `ec2.amazonaws.com` to assume the role.

Key distinction:

- Trust policy controls who can assume the role.
- Permission policy controls what the role can do.
- EC2 uses an instance profile to attach a role to an instance.
- STS issues temporary credentials for the assumed role.
- IMDSv2 exposes those temporary credentials to processes running on the instance.

## Initial permissions

Allowed:

- `sts:GetCallerIdentity`
- `s3:ListAllMyBuckets`

Expected denied actions later:

- `ec2:DescribeInstances`
- `iam:ListRoles`
- `secretsmanager:ListSecrets`