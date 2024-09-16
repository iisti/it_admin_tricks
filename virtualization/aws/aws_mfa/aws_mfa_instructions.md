# AWS MFA Instructions

## Enable MFA/2FA in AWS

1. Login into https://aws.amazon.com
1. Click right up corner username@AWS_ACCOUNT_ID -> Security credentials
1. Set up device
1. There should be green header banner informing:
    
    > MFA device assigned
    > 
    > You can register up to 8 MFA devices of any combination of the currently supported MFA types with your AWS account root and IAM user. With multiple MFA devices, you only need one MFA device to sign in to the AWS console or create a session through the AWS CLI with that user.
  
1. Logout / login, so that AWS console realises that your permissions have been updated.

## How to use AWS CLI with MFA

One can export MFA session token with the script below on WSL / Linux. The script has been also saved to, but the repo is available only for DevOps team.

The session token which is retrieved is valid 12 hours.

### MFA script usage
1. Save the script in WSL / Linux
1. Make it executable
1. If you don’t have jq installed, you can install it with apt update && apt install jq in Ubuntu/Debian.
1. Run the script and give MFA code from your MFA application (probably a phone app).
1. One can also create an alias for the script in `~/.bashrc`

    ~~~shell
    # Creating alias for aws_mfa
    alias aws_mfa="<script_path>/aws_mfa_get_token.sh"
    ~~~

## Create a policy to prevent actions if MFA is not enabled
1. Create a policy DenyAccessWithoutMFA. Policy is copied from the link below
    * Notice that line "iam:ChangePassword" needs to be added to section "Sid": "BlockMostAccessUnlessSignedInWithMFA", otherwise first time login doesn’t work if user is forced to change password.

    ~~~json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "AllowListActions",
                "Effect": "Allow",
                "Action": [
                    "iam:ListUsers",
                    "iam:ListVirtualMFADevices"
                ],
                "Resource": "*"
            },
            {
                "Sid": "AllowUserToCreateVirtualMFADevice",
                "Effect": "Allow",
                "Action": [
                    "iam:CreateVirtualMFADevice"
                ],
                "Resource": "arn:aws:iam::*:mfa/*"
            },
            {
                "Sid": "AllowUserToManageTheirOwnMFA",
                "Effect": "Allow",
                "Action": [
                    "iam:EnableMFADevice",
                    "iam:ListMFADevices",
                    "iam:ResyncMFADevice"
                ],
                "Resource": "arn:aws:iam::*:user/${aws:username}"
            },
            {
                "Sid": "AllowUserToDeactivateTheirOwnMFAOnlyWhenUsingMFA",
                "Effect": "Allow",
                "Action": [
                    "iam:DeactivateMFADevice"
                ],
                "Resource": [
                    "arn:aws:iam::*:user/${aws:username}"
                ],
                "Condition": {
                    "Bool": {
                        "aws:MultiFactorAuthPresent": "true"
                    }
                }
            },
            {
                "Sid": "BlockMostAccessUnlessSignedInWithMFA",
                "Effect": "Deny",
                "NotAction": [
                    "iam:CreateVirtualMFADevice",
                    "iam:EnableMFADevice",
                    "iam:ListMFADevices",
                    "iam:ListUsers",
                    "iam:ListVirtualMFADevices",
                    "iam:ResyncMFADevice",
                    "iam:ChangePassword"
                ],
                "Resource": "*",
                "Condition": {
                    "BoolIfExists": {
                        "aws:MultiFactorAuthPresent": "false"
                    }
                }
            }
        ]
    }
    ~~~

    * Notice that even the BoolIfExists is recommended, AWS docs have the following remarks, source https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_condition-keys.html

      > This combination of `Deny`, `BoolIfExists`, and `false` denies requests that are not authenticated using MFA. Specifically, it denies requests from temporary credentials that do not include MFA. It also denies requests that are made using long-term credentials, such as AWS CLI or AWS API operations made using access keys. The `*IfExists` operator checks for the presence of the `aws:MultiFactorAuthPresent` key and whether or not it could be present, as indicated by its existence. Use this when you want to deny any request that is not authenticated using MFA. This is more secure, but can break any code or scripts that use access keys to access the AWS CLI or AWS API. 
1. Create a policy AllowMySecurityCredentialsDetails

   ~~~json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "AllowListActions",
                "Effect": "Allow",
                "Action": [
                    "iam:GetLoginProfile",
                    "iam:ListMFADevices",
                    "iam:ListAccessKeys",
                    "iam:ListSigningCertificates"
                ],
                "Resource": "arn:aws:iam::*:user/${aws:username}"
            }
        ]
    }
    ~~~

1. Create a group require-mfa and attach the policies into that group.
1. Put users into that group.
    
