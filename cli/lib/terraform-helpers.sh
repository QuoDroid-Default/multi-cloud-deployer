#!/usr/bin/env bash

################################################################################
# Terraform helper functions
################################################################################

cleanup_orphaned_resources() {
    local env=$1

    print_info "Cleaning up orphaned resources from previous failed deployments..."

    if [ "$CLOUD_PROVIDER" == "aws" ]; then
        # Delete orphaned ElastiCache cluster first (if exists)
        local cache_clusters=$(aws elasticache describe-cache-clusters \
            --query "CacheClusters[?starts_with(CacheClusterId, '${env}-cache')].CacheClusterId" \
            --region "$REGION" \
            --output text 2>/dev/null)

        if [ -n "$cache_clusters" ]; then
            for cluster_id in $cache_clusters; do
                print_info "Deleting orphaned ElastiCache cluster: $cluster_id"
                aws elasticache delete-cache-cluster \
                    --cache-cluster-id "$cluster_id" \
                    --region "$REGION" 2>/dev/null || true
            done
            # Wait for cluster deletion to complete
            print_info "Waiting for ElastiCache cluster deletion..."
            sleep 10
        fi

        # Delete orphaned RDS instance first (if exists)
        local rds_instances=$(aws rds describe-db-instances \
            --query "DBInstances[?starts_with(DBInstanceIdentifier, '${env}-db')].DBInstanceIdentifier" \
            --region "$REGION" \
            --output text 2>/dev/null)

        if [ -n "$rds_instances" ]; then
            for instance_id in $rds_instances; do
                print_info "Deleting orphaned RDS instance: $instance_id"
                aws rds delete-db-instance \
                    --db-instance-identifier "$instance_id" \
                    --skip-final-snapshot \
                    --region "$REGION" 2>/dev/null || true
            done
            # Wait for instance deletion to start
            print_info "Waiting for RDS instance deletion..."
            sleep 10
        fi

        # Now delete subnet groups (should work now that clusters are gone)
        if aws rds describe-db-subnet-groups \
            --db-subnet-group-name "${env}-db-subnet-group" \
            --region "$REGION" &>/dev/null; then
            print_info "Deleting orphaned DB subnet group: ${env}-db-subnet-group"
            aws rds delete-db-subnet-group \
                --db-subnet-group-name "${env}-db-subnet-group" \
                --region "$REGION" 2>/dev/null || print_warning "Failed to delete DB subnet group (may still be in use)"
        fi

        if aws elasticache describe-cache-subnet-groups \
            --cache-subnet-group-name "${env}-cache-subnet-group" \
            --region "$REGION" &>/dev/null; then
            print_info "Deleting orphaned ElastiCache subnet group: ${env}-cache-subnet-group"
            aws elasticache delete-cache-subnet-group \
                --cache-subnet-group-name "${env}-cache-subnet-group" \
                --region "$REGION" 2>/dev/null || print_warning "Failed to delete ElastiCache subnet group (may still be in use)"
        fi

        print_success "Cleanup complete"
    fi
}

terraform_init() {
    local env=$1

    print_info "Initializing Terraform for $CLOUD_PROVIDER..."

    # Use cloud-specific directory (2026 best practice)
    local tf_dir="$DEPLOYER_ROOT/terraform/$CLOUD_PROVIDER"
    local state_dir="$WORK_DIR/.deployer/terraform/state"

    mkdir -p "$state_dir"

    # Validate cloud-specific directory exists
    if [ ! -d "$tf_dir" ]; then
        print_error "Terraform configuration for '$CLOUD_PROVIDER' not found at $tf_dir"
        echo "Supported cloud providers: aws, azure"
        exit 1
    fi

    # Validate Azure credentials if deploying to Azure
    if [ "$CLOUD_PROVIDER" == "azure" ]; then
        if [ -z "$ARM_SUBSCRIPTION_ID" ] || [ -z "$ARM_CLIENT_ID" ]; then
            print_error "Azure credentials not configured!"
            echo "Set these environment variables:"
            echo "  ARM_SUBSCRIPTION_ID"
            echo "  ARM_CLIENT_ID"
            echo "  ARM_CLIENT_SECRET"
            echo "  ARM_TENANT_ID"
            exit 1
        fi
    fi

    cd "$tf_dir"

    # Initialize with backend configuration
    terraform init \
        -backend-config="path=$state_dir/${env}.tfstate" \
        -reconfigure

    cd "$WORK_DIR"

    print_success "Terraform initialized for $CLOUD_PROVIDER"
}

terraform_plan() {
    local env=$1

    print_info "Planning infrastructure changes for $CLOUD_PROVIDER..."

    generate_tfvars "$env"

    local tf_dir="$DEPLOYER_ROOT/terraform/$CLOUD_PROVIDER"
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

    print_info "Applying infrastructure changes for $CLOUD_PROVIDER..."

    local tf_dir="$DEPLOYER_ROOT/terraform/$CLOUD_PROVIDER"
    local plan_file="$WORK_DIR/.deployer/terraform/${env}.tfplan"

    cd "$tf_dir"

    terraform apply "$plan_file"

    # Save outputs
    terraform output -json > "$WORK_DIR/.deployer/terraform/${env}-outputs.json"

    cd "$WORK_DIR"

    print_success "Infrastructure created on $CLOUD_PROVIDER"
}

terraform_destroy() {
    local env=$1

    print_info "Destroying infrastructure on $CLOUD_PROVIDER..."

    local tf_dir="$DEPLOYER_ROOT/terraform/$CLOUD_PROVIDER"
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

    print_info "Terraform state for $CLOUD_PROVIDER:"

    local tf_dir="$DEPLOYER_ROOT/terraform/$CLOUD_PROVIDER"

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
