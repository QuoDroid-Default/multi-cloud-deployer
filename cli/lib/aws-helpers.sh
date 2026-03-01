#!/usr/bin/env bash

################################################################################
# AWS helper functions
################################################################################

aws_validate_credentials() {
    if ! command_exists aws; then
        print_error "AWS CLI not installed"
        exit 1
    fi

    if ! aws sts get-caller-identity &>/dev/null; then
        print_error "AWS credentials not configured"
        echo ""
        echo "Configure AWS credentials:"
        echo "  aws configure"
        exit 1
    fi

    print_success "AWS credentials validated"
}

aws_get_secret() {
    local secret_name=$1
    local region=${2:-us-east-1}

    aws secretsmanager get-secret-value \
        --secret-id "$secret_name" \
        --region "$region" \
        --query 'SecretString' \
        --output text
}

aws_put_secret() {
    local secret_name=$1
    local secret_value=$2
    local region=${3:-us-east-1}

    aws secretsmanager put-secret-value \
        --secret-id "$secret_name" \
        --secret-string "$secret_value" \
        --region "$region"
}
