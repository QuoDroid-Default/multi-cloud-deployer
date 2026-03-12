#!/usr/bin/env bash

################################################################################
# Common utility functions
################################################################################

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get absolute path
abs_path() {
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

# Load size preset from YAML
load_size_preset() {
    local preset=$1
    local cloud=$2
    local presets_file="${CONFIG_DIR}/size-presets.yaml"

    if [ ! -f "$presets_file" ]; then
        print_error "Size presets file not found: $presets_file"
        exit 1
    fi

    # Extract values using yq
    export INSTANCE_TYPE=$(yq eval ".presets.${preset}.${cloud}.compute.instance_type" "$presets_file")
    export INSTANCE_COUNT=$(yq eval ".presets.${preset}.${cloud}.compute.instance_count" "$presets_file")
    export DB_INSTANCE_CLASS=$(yq eval ".presets.${preset}.${cloud}.database.instance_class" "$presets_file")
    export DB_STORAGE=$(yq eval ".presets.${preset}.${cloud}.database.allocated_storage" "$presets_file")
    export CACHE_NODE_TYPE=$(yq eval ".presets.${preset}.${cloud}.cache.node_type" "$presets_file")

    # Check for environment-specific overrides
    if [ -n "$ENV_FILE" ] && [ -f "$ENV_FILE" ]; then
        local override_count=$(yq eval '.infrastructure.compute.autoscaling.max_instances // ""' "$ENV_FILE")
        if [ -n "$override_count" ] && [ "$override_count" != "null" ]; then
            print_info "  Override: Using $override_count instance(s) from environment config"
            export INSTANCE_COUNT=$override_count
        fi
    fi

    print_success "Loaded size preset: $preset ($cloud)"
    print_info "  Compute: $INSTANCE_TYPE x $INSTANCE_COUNT"
    print_info "  Database: $DB_INSTANCE_CLASS ($DB_STORAGE GB)"
    print_info "  Cache: $CACHE_NODE_TYPE"
}

# Build applications
build_applications() {
    if [ -z "$CLONE_DIR" ]; then
        print_warning "No CLONE_DIR set - skipping application build"
        return 0
    fi

    # Build frontend if exists
    if [ -d "$CLONE_DIR/frontend" ]; then
        print_info "Building frontend..."
        cd "$CLONE_DIR/frontend"

        if [ -f "package.json" ]; then
            npm install --quiet
            npm run build
            print_success "Frontend built successfully"
        fi

        cd "$WORK_DIR"
    fi

    # Prepare backend if exists
    if [ -d "$CLONE_DIR/backend" ]; then
        print_info "Preparing backend..."
        cd "$CLONE_DIR/backend"

        if [ -f "requirements.txt" ]; then
            # Don't install here - will install on server via Ansible
            print_success "Backend prepared"
        fi

        cd "$WORK_DIR"
    fi
}

# Show deployment URLs
show_deployment_urls() {
    local env=$1
    local env_file="$DEPLOYER_DIR/environments/${env}.yaml"

    local webapp_domain=$(yq eval '.domain.webapp // "null"' "$env_file")
    local api_domain=$(yq eval '.domain.api // "null"' "$env_file")

    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  Deployment Successful!                                       ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if [ "$webapp_domain" != "null" ]; then
        echo -e "  ${BLUE}Web App:${NC}  https://$webapp_domain"
    fi

    if [ "$api_domain" != "null" ]; then
        echo -e "  ${BLUE}API:${NC}      https://$api_domain"
        echo -e "  ${BLUE}Health:${NC}   https://$api_domain/api/health/"
    fi

    echo ""
}

# Generate Terraform tfvars from environment config
generate_tfvars() {
    local env=$1
    local env_file="$DEPLOYER_DIR/environments/${env}.yaml"
    local output_file="$WORK_DIR/.deployer/terraform/${env}.tfvars"

    mkdir -p "$(dirname "$output_file")"

    # Load size preset (with environment file for overrides)
    ENV_FILE="$env_file" load_size_preset "$SIZE_PRESET" "$CLOUD_PROVIDER"

    # Read infrastructure overrides from environment file
    local db_backup_days=$(yq eval '.infrastructure.database.backup_retention_days // 7' "$env_file")
    local db_multi_az=$(yq eval '.infrastructure.database.multi_az // false' "$env_file")
    local db_encrypted=$(yq eval '.infrastructure.database.storage_encrypted // false' "$env_file")

    local cache_failover=$(yq eval '.infrastructure.cache.automatic_failover // false' "$env_file")
    local cache_nodes=$(yq eval '.infrastructure.cache.num_cache_nodes // 1' "$env_file")

    local storage_versioning=$(yq eval '.infrastructure.storage.versioning // false' "$env_file")

    # Read compute overrides
    local root_volume_size=$(yq eval '.infrastructure.compute.root_volume_size // 30' "$env_file")

    # Read CDN/DNS settings
    local enable_cdn=$(yq eval '.infrastructure.cdn.enabled // false' "$env_file")
    local enable_dns=$(yq eval '.infrastructure.dns.enabled // false' "$env_file")

    # Read test execution settings
    local test_exec_enabled=$(yq eval '.infrastructure.test_execution.enabled // false' "$env_file")
    local test_exec_executor=$(yq eval '.infrastructure.test_execution.executor // "docker"' "$env_file")
    local test_exec_cpu=$(yq eval '.infrastructure.test_execution.cpu // "1024"' "$env_file")
    local test_exec_memory=$(yq eval '.infrastructure.test_execution.memory // "2048"' "$env_file")

    # Generate tfvars
    cat > "$output_file" <<EOF
# Auto-generated by cloud-deploy
# Environment: $env
# Generated: $(date)

environment = "$env"
cloud_provider = "$CLOUD_PROVIDER"
region = "$REGION"

# Compute
instance_type = "$INSTANCE_TYPE"
instance_count = $INSTANCE_COUNT
root_volume_size = $root_volume_size

# Database
database_engine = "postgres"
database_engine_version = "15"
database_instance_class = "$DB_INSTANCE_CLASS"
database_allocated_storage = $DB_STORAGE
database_name = "app_db"
database_multi_az = $db_multi_az
database_backup_retention_days = $db_backup_days
database_storage_encrypted = $db_encrypted

# Cache
cache_engine = "redis"
cache_engine_version = "7.0"
cache_node_type = "$CACHE_NODE_TYPE"
cache_num_nodes = $cache_nodes
cache_automatic_failover = $cache_failover

# Storage
storage_buckets = ["artifacts", "static"]
storage_versioning = $storage_versioning

# CDN & DNS
enable_cdn = $enable_cdn
enable_dns = $enable_dns

# Test Execution
enable_test_execution = $([ "$test_exec_executor" = "fargate" ] && echo "true" || echo "false")
test_execution_cpu = "$test_exec_cpu"
test_execution_memory = "$test_exec_memory"

EOF

    # Add domain configuration if present
    local webapp_domain=$(yq eval '.domain.webapp // ""' "$env_file")
    if [ -n "$webapp_domain" ] && [ "$webapp_domain" != "null" ]; then
        echo "webapp_domain = \"$webapp_domain\"" >> "$output_file"
    fi

    local api_domain=$(yq eval '.domain.api // ""' "$env_file")
    if [ -n "$api_domain" ] && [ "$api_domain" != "null" ]; then
        echo "api_domain = \"$api_domain\"" >> "$output_file"
    fi

    # Add tags
    echo "" >> "$output_file"
    echo "# Tags" >> "$output_file"
    echo "tags = {" >> "$output_file"
    yq eval '.tags | to_entries | .[] | "  \"" + .key + "\" = \"" + .value + "\""' "$env_file" >> "$output_file"
    echo "}" >> "$output_file"

    print_success "Generated tfvars: $output_file"
}
