# EC2 Workload Identity / IMDSv2 Credential Replay Lab

## Overview

This lab demonstrates how an EC2 instance with an attached IAM role receives temporary STS credentials through the Instance Metadata Service v2 (IMDSv2), and how those credentials can be replayed outside the instance if obtained by an attacker.

The lab focuses on attacker-to-defender reasoning: retrieve workload credentials, test their permissions, observe denied actions, and design guardrails to reduce blast radius.

## Objective

- Create a minimal EC2 workload identity using Terraform.
- Attach a limited IAM role to an EC2 instance through an instance profile.
- Require IMDSv2 on the instance.
- Retrieve temporary role credentials from inside the instance.
- Replay those credentials locally using the AWS CLI.
- Test allowed and denied AWS API calls.
- Document guardrails that reduce the impact of workload credential theft.

## Architecture

EC2 instance  
→ IAM instance profile  
→ IAM role  
→ IMDSv2  
→ temporary STS credentials  
→ AWS API calls

## Terraform Resources

This lab creates:

- `aws_iam_role`
- `aws_iam_role_policy`
- `aws_iam_instance_profile`
- `aws_security_group`
- `aws_instance`

The IAM role trusts the EC2 service principal:

```hcl
Service = "ec2.amazonaws.com"