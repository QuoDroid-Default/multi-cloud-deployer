#!/usr/bin/env bash

################################################################################
# Terraform helper functions
################################################################################

terraform_init() {
    local env=$1

    print_info "Initializing Terraform..."

    local tf_dir="$DEPLOYER_ROOT/terraform"
    local state_dir="$WORK_DIR/.deployer/terraform/state"

    mkdir -p "$state_dir"

    cd "$tf_dir"

    # Set dummy Azure credentials if deploying to AWS
    if [ "$CLOUD_PROVIDER" == "aws" ]; then
        export ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID:-00000000-0000-0000-0000-000000000000}"
        export ARM_CLIENT_ID="${ARM_CLIENT_ID:-00000000-0000-0000-0000-000000000000}"
        export ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET:-dummy-secret}"
        export ARM_TENANT_ID="${ARM_TENANT_ID:-00000000-0000-0000-0000-000000000000}"
    fi

    # Initialize with backend configuration
    terraform init \
        -backend-config="path=$state_dir/${env}.tfstate" \
        -reconfigure

    cd "$WORK_DIR"

    print_success "Terraform initialized"
}

terraform_plan() {
    local env=$1

    print_info "Planning infrastructure changes..."

    generate_tfvars "$env"

    local tf_dir="$DEPLOYER_ROOT/terraform"
    local tfvars_file="$WORK_DIR/.deployer/terraform/${env}.tfvars"

    cd "$tf_dir"

    terraform plan \
        -var-file="$tfvars_file" \
        -out="$WORK_DIR/.deployer/terraform/${env}.tfplan"

    cd "$WORK_DIR"

    print_success "Terraform plan complete"
}

terraform_apply() {
    local env=$1

    print_info "Applying infrastructure changes..."

    local tf_dir="$DEPLOYER_ROOT/terraform"
    local plan_file="$WORK_DIR/.deployer/terraform/${env}.tfplan"

    cd "$tf_dir"

    terraform apply "$plan_file"

    # Save outputs
    terraform output -json > "$WORK_DIR/.deployer/terraform/${env}-outputs.json"

    cd "$WORK_DIR"

    print_success "Infrastructure created"
}

terraform_destroy() {
    local env=$1

    print_info "Destroying infrastructure..."

    local tf_dir="$DEPLOYER_ROOT/terraform"
    local tfvars_file="$WORK_DIR/.deployer/terraform/${env}.tfvars"

    cd "$tf_dir"

    terraform destroy \
        -var-file="$tfvars_file" \
        -auto-approve

    cd "$WORK_DIR"

    print_success "Infrastructure destroyed"
}

terraform_status() {
    local env=$1

    print_info "Terraform state:"

    local tf_dir="$DEPLOYER_ROOT/terraform"

    cd "$tf_dir"

    terraform show -json | jq -r '.values.root_module.resources[] | "\(.type): \(.name)"'

    cd "$WORK_DIR"
}

terraform_output() {
    local env=$1
    local key=$2

    local outputs_file="$WORK_DIR/.deployer/terraform/${env}-outputs.json"

    if [ ! -f "$outputs_file" ]; then
        print_error "No outputs found for $env"
        return 1
    fi

    jq -r ".${key}.value" "$outputs_file"
}
