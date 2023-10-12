#!/bin/bash

# Check that jq is installed and give instructions if jq is not installed.
# redirects: 1st stderr to null and 2nd stdout to null, so nothing is printed on console
if ! jq --version 2> /dev/null | grep "jq-" 1> /dev/null
then
    echo "Package jq is required. Install the pacakge before running this script."
        cat << EOF
# One can run these command separately without the script and automation.
# Check the arn of the mfa device
aws iam list-mfa-devices
# Get the session credentials
aws sts get-session-token --serial-number <arn-of-the-mfa-device> --token-code <code-from-mfa-device>
# Export the credentials
export AWS_ACCESS_KEY_ID=access-key-as-in-previous-output
export AWS_SECRET_ACCESS_KEY=access-key-as-in-previous-output
export AWS_SESSION_TOKEN=session-token-as-in-previous-output
# Exports can be checked by running command "export"
EOF
    exit 1
fi

# Unset the old tokens
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN


echo "Give AWS MFA Code:"
read aws_token
aws sts get-session-token \
    --serial-number $(aws iam list-mfa-devices | jq -r .[][0].SerialNumber) \
    --token-code "$aws_token" \
    > ~/.aws_session_token.json

cat << EOL >> ~/.aws_tmp_session_token_export.conf
export AWS_ACCESS_KEY_ID=$(jq -r .Credentials.AccessKeyId ~/.aws_session_token.json)
export AWS_SECRET_ACCESS_KEY=$(jq -r .Credentials.SecretAccessKey ~/.aws_session_token.json)
export AWS_SESSION_TOKEN=$(jq -r .Credentials.SessionToken ~/.aws_session_token.json)
EOL

echo "Exports can be checked by running command \"export\""
echo "Run the line below to export environment variables. Because the exported environment variables are tied to the running shell process, you need to run the line in every shell if you want to use multiple shells."
echo "source ~/.aws_tmp_session_token_export.conf; rm -f ~/.aws_session_token.json"
