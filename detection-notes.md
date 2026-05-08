
# Detection Notes: Stolen EC2 Role Credential Replay

## Detection Question

If EC2 role credentials are retrieved from IMDSv2 and replayed outside the instance, what evidence appears in CloudTrail?

## Lab Context

In the EC2 Workload Identity / IMDSv2 lab, an EC2 instance was launched with an attached IAM role. Temporary STS credentials were retrieved from IMDSv2 and configured locally as an AWS CLI profile.

The replayed credentials were then used from a local machine to call AWS APIs.

## Hypothesis

CloudTrail should show API calls made by the assumed EC2 role session.

If the credentials are replayed from outside the EC2 instance, useful investigation signals may include:

- Source IP address different from the EC2 instance’s expected network path.
- User agent showing AWS CLI usage from a local machine.
- API calls that are unusual for the workload role.
- Denied API calls indicating permission probing.

## Events to Investigate

Relevant API calls from the lab:

- `GetCallerIdentity`
- `ListBuckets`
- `DescribeInstances`
- `ListRoles`
- `ListSecrets`

## Fields to Review in CloudTrail

Important CloudTrail fields:

- `eventTime`
- `eventName`
- `eventSource`
- `userIdentity.type`
- `userIdentity.arn`
- `userIdentity.sessionContext`
- `sourceIPAddress`
- `userAgent`
- `errorCode`
- `errorMessage`
- `awsRegion`

## Expected Findings

Allowed calls should appear as successful events from the assumed EC2 role.

Denied calls should show errors such as:

- `AccessDenied`
- `AccessDeniedException`
- `UnauthorizedOperation`

The key identity pattern to look for is:

```text
arn:aws:sts::ACCOUNT_ID:assumed-role/pd-ec2-limited-imdsv2-role/INSTANCE_ID
