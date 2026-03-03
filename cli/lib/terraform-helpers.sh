#!/usr/bin/env bash

################################################################################
# Terraform helper functions
################################################################################

cleanup_orphaned_resources() {
    local env=$1

    print_info "Cleaning up orphaned resources from previous failed deployments..."

    if [ "$CLOUD_PROVIDER" == "aws" ]; then
        # Try to delete subnet groups first (they might already be orphaned)
        local db_group_deleted=false
        local cache_group_deleted=false

        # Try DB subnet group deletion
        if aws rds describe-db-subnet-groups \
            --db-subnet-group-name "${env}-db-subnet-group" \
            --region "$REGION" &>/dev/null; then
            print_info "Attempting to delete DB subnet group: ${env}-db-subnet-group"
            if aws rds delete-db-subnet-group \
                --db-subnet-group-name "${env}-db-subnet-group" \
                --region "$REGION" 2>/dev/null; then
                print_success "Deleted DB subnet group"
                db_group_deleted=true
            else
                print_warning "DB subnet group in use, checking for dependent resources..."

                # Find and delete any RDS instances using it
                local rds_instances=$(aws rds describe-db-instances \
                    --query "DBInstances[?DBSubnetGroup.DBSubnetGroupName=='${env}-db-subnet-group'].DBInstanceIdentifier" \
                    --region "$REGION" \
                    --output text 2>/dev/null)

                if [ -n "$rds_instances" ]; then
                    for instance_id in $rds_instances; do
                        print_info "Deleting RDS instance using subnet group: $instance_id"
                        aws rds delete-db-instance \
                            --db-instance-identifier "$instance_id" \
                            --skip-final-snapshot \
                            --region "$REGION" 2>/dev/null || true
                    done
                    print_info "Waiting 15 seconds for RDS deletion to start..."
                    sleep 15

                    # Try deleting subnet group again
                    aws rds delete-db-subnet-group \
                        --db-subnet-group-name "${env}-db-subnet-group" \
                        --region "$REGION" 2>/dev/null && db_group_deleted=true || true
                fi
            fi
        fi

        # Try ElastiCache subnet group deletion
        if aws elasticache describe-cache-subnet-groups \
            --cache-subnet-group-name "${env}-cache-subnet-group" \
            --region "$REGION" &>/dev/null; then
            print_info "Attempting to delete ElastiCache subnet group: ${env}-cache-subnet-group"
            if aws elasticache delete-cache-subnet-group \
                --cache-subnet-group-name "${env}-cache-subnet-group" \
                --region "$REGION" 2>/dev/null; then
                print_success "Deleted ElastiCache subnet group"
                cache_group_deleted=true
            else
                print_warning "ElastiCache subnet group in use, checking for dependent resources..."

                # Find and delete any clusters using it
                local cache_clusters=$(aws elasticache describe-cache-clusters \
                    --query "CacheClusters[?CacheSubnetGroupName=='${env}-cache-subnet-group'].CacheClusterId" \
                    --region "$REGION" \
                    --output text 2>/dev/null)

                if [ -n "$cache_clusters" ]; then
                    for cluster_id in $cache_clusters; do
                        print_info "Deleting ElastiCache cluster using subnet group: $cluster_id"
                        aws elasticache delete-cache-cluster \
                            --cache-cluster-id "$cluster_id" \
                            --region "$REGION" 2>/dev/null || true
                    done
                    print_info "Waiting 15 seconds for ElastiCache deletion to start..."
                    sleep 15

                    # Try deleting subnet group again
                    aws elasticache delete-cache-subnet-group \
                        --cache-subnet-group-name "${env}-cache-subnet-group" \
                        --region "$REGION" 2>/dev/null && cache_group_deleted=true || true
                fi
            fi
        fi

        [ "$db_group_deleted" = true ] || [ "$cache_group_deleted" = true ] && print_success "Cleanup complete" || print_info "No orphaned resources found"
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

    # Save outputs with error handling
    local outputs_file="$WORK_DIR/.deployer/terraform/${env}-outputs.json"
    print_info "Saving Terraform outputs..."

    if terraform output -json > "$outputs_file" 2>&1; then
        print_success "Terraform outputs saved"
    else
        print_error "Failed to save Terraform outputs"
        cat "$outputs_file"
        exit 1
    fi

    # Validate JSON
    if ! jq empty "$outputs_file" 2>/dev/null; then
        print_error "Invalid JSON in outputs file"
        cat "$outputs_file"
        exit 1
    fi

    cd "$WORK_DIR"

    print_success "Infrastructure created on $CLOUD_PROVIDER"
}

terraform_destroy() {
    local env=$1

    print_info "Destroying infrastructure on $CLOUD_PROVIDER..."

    local tf_dir="$DEPLOYER_ROOT/terraform/$CLOUD_PROVIDER"
    local tfvars_file="$WORK_DIR/.deployer/terraform/${env}.tfvars"

    # AWS-specific pre-destroy cleanup
    if [ "$CLOUD_PROVIDER" == "aws" ]; then
        print_info "Cleaning up subnet groups before destroy..."

        # Try to delete DB subnet groups
        aws rds delete-db-subnet-group \
            --db-subnet-group-name "${env}-db-subnet-group" \
            --region "$REGION" 2>/dev/null && print_success "Deleted DB subnet group" || true

        # Try to delete ElastiCache subnet groups
        aws elasticache delete-cache-subnet-group \
            --cache-subnet-group-name "${env}-cache-subnet-group" \
            --region "$REGION" 2>/dev/null && print_success "Deleted ElastiCache subnet group" || true

        sleep 5
    fi

    cd "$tf_dir"

    # 2026 Best Practice: Generate tfvars if missing (for incomplete deployments)
    if [ ! -f "$tfvars_file" ]; then
        print_warning "tfvars file not found, generating for destroy..."
        generate_tfvars "$env"
    fi

    # 2026 Best Practice: Destroy using state, retry if needed
    print_info "Running Terraform destroy..."
    if ! terraform destroy \
        -var-file="$tfvars_file" \
        -auto-approve 2>&1; then

        print_warning "Initial destroy failed, retrying with refresh..."
        terraform refresh -var-file="$tfvars_file" || true

        # Try again
        terraform destroy \
            -var-file="$tfvars_file" \
            -auto-approve
    fi

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
