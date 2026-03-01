#!/usr/bin/env bash

################################################################################
# Azure helper functions
################################################################################

azure_validate_credentials() {
    if ! command_exists az; then
        print_error "Azure CLI not installed"
        exit 1
    fi

    if ! az account show &>/dev/null; then
        print_error "Azure credentials not configured"
        echo ""
        echo "Login to Azure:"
        echo "  az login"
        exit 1
    fi

    print_success "Azure credentials validated"
}

azure_get_secret() {
    local vault_name=$1
    local secret_name=$2

    az keyvault secret show \
        --vault-name "$vault_name" \
        --name "$secret_name" \
        --query 'value' \
        --output tsv
}

azure_set_secret() {
    local vault_name=$1
    local secret_name=$2
    local secret_value=$3

    az keyvault secret set \
        --vault-name "$vault_name" \
        --name "$secret_name" \
        --value "$secret_value"
}
