#!/usr/bin/env bash

################################################################################
# Ansible helper functions
################################################################################

ansible_deploy() {
    local env=$1

    print_info "Deploying application with Ansible..."

    local playbook="$DEPLOYER_ROOT/ansible/playbooks/deploy-fullstack.yml"
    local inventory_file="$WORK_DIR/.deployer/ansible/${env}-inventory.ini"
    local outputs_file="$WORK_DIR/.deployer/terraform/${env}-outputs.json"

    # Generate inventory from Terraform outputs
    generate_ansible_inventory "$env"

    # Extract configuration from Terraform outputs
    print_info "Extracting configuration from Terraform outputs..."

    # Validate outputs file is valid JSON
    if ! jq empty "$outputs_file" 2>/dev/null; then
        print_error "Invalid JSON in Terraform outputs file"
        exit 1
    fi

    local db_endpoint=$(jq -r '.database_endpoint.value // ""' "$outputs_file" 2>/dev/null | cut -d: -f1)
    local db_port=$(jq -r '.database_port.value // "5432"' "$outputs_file" 2>/dev/null)
    local db_name=$(jq -r '.database_name.value // ""' "$outputs_file" 2>/dev/null)
    local db_password=$(jq -r '.database_password.value // ""' "$outputs_file" 2>/dev/null)

    local cache_endpoint=$(jq -r '.cache_endpoint.value // ""' "$outputs_file" 2>/dev/null)
    local cache_port=$(jq -r '.cache_port.value // "6379"' "$outputs_file" 2>/dev/null)

    # Validate required values
    if [ -z "$db_endpoint" ] || [ -z "$db_name" ] || [ -z "$db_password" ]; then
        print_error "Missing required database configuration"
        print_info "DB endpoint: $db_endpoint"
        print_info "DB name: $db_name"
        exit 1
    fi

    if [ -z "$cache_endpoint" ]; then
        print_error "Missing required cache configuration"
        exit 1
    fi

    # Generate random secret key for Django (using Python for reliability)
    local secret_key=$(python3 -c "import secrets; print(secrets.token_urlsafe(50))")

    # Get first instance IP and DNS for ALLOWED_HOSTS
    local first_ip=$(cat "$inventory_file" | grep -E '^[0-9]' | head -1 | awk '{print $1}')

    # Get EC2 public DNS name (for CloudFront origin)
    local ec2_dns=$(terraform_output "$env" "instance_public_ips" 2>/dev/null | jq -r '.[0]' 2>/dev/null || echo "")

    # Get CloudFront domain if CDN is enabled
    local cdn_domain=$(terraform_output "$env" "cdn_domain" 2>/dev/null || echo "")

    # Build ALLOWED_HOSTS list (2026 best practice: include all access points)
    local allowed_hosts="$first_ip,localhost,127.0.0.1,.cloudfront.net"
    [ -n "$cdn_domain" ] && [ "$cdn_domain" != "null" ] && allowed_hosts="$allowed_hosts,$cdn_domain"

    # Read test execution settings from environment config
    local env_file="$WORK_DIR/.deployer/environments/${env}.yaml"
    local test_executor="docker"  # Default
    if [ -f "$env_file" ]; then
        test_executor=$(yq eval '.infrastructure.test_execution.executor // "docker"' "$env_file")
    fi

    print_success "Configuration extracted successfully"

    # Run Ansible playbook
    cd "$DEPLOYER_ROOT/ansible"

    # Get Claude credentials from environment (set by deployment workflow)
    local claude_creds="${CLAUDE_CREDENTIALS_JSON:-}"

    ANSIBLE_ROLES_PATH="$DEPLOYER_ROOT/ansible/roles" ansible-playbook \
        -i "$inventory_file" \
        "$playbook" \
        -e "env_name=$env" \
        -e "clone_dir=$CLONE_DIR" \
        -e "config_dir=$DEPLOYER_DIR" \
        -e "database_host=$db_endpoint" \
        -e "database_port=$db_port" \
        -e "database_name=$db_name" \
        -e "database_user=dbadmin" \
        -e "database_password=$db_password" \
        -e "cache_host=$cache_endpoint" \
        -e "cache_port=$cache_port" \
        -e "django_secret_key=$secret_key" \
        -e "django_allowed_hosts=$allowed_hosts" \
        -e "cdn_domain=$cdn_domain" \
        -e "test_executor=$test_executor" \
        -e "claude_credentials_json=$claude_creds"

    cd "$WORK_DIR"

    print_success "Application deployed"
}

ansible_status() {
    local env=$1

    print_info "Application status:"

    local inventory_file="$WORK_DIR/.deployer/ansible/${env}-inventory.ini"

    if [ ! -f "$inventory_file" ]; then
        print_warning "No inventory found for $env"
        return 1
    fi

    cd "$DEPLOYER_ROOT/ansible"

    ansible all \
        -i "$inventory_file" \
        -m shell \
        -a "systemctl status coco-* --no-pager | grep Active" \
        2>/dev/null || true

    cd "$WORK_DIR"
}

generate_ansible_inventory() {
    local env=$1
    local inventory_file="$WORK_DIR/.deployer/ansible/${env}-inventory.ini"
    local outputs_file="$WORK_DIR/.deployer/terraform/${env}-outputs.json"

    mkdir -p "$(dirname "$inventory_file")"

    # Check if outputs file exists
    if [ ! -f "$outputs_file" ]; then
        print_error "Terraform outputs file not found: $outputs_file"
        print_info "Run 'terraform output -json' to generate outputs"
        exit 1
    fi

    # Validate outputs file is valid JSON first
    if ! jq empty "$outputs_file" 2>/dev/null; then
        print_error "Invalid JSON in Terraform outputs file"
        print_info "File contents:"
        head -20 "$outputs_file"
        exit 1
    fi

    # Get EC2 instance public IPs from Terraform outputs
    print_info "Reading instance IPs from: $outputs_file"

    # Check if instance_public_ips exists in outputs
    if ! jq -e '.instance_public_ips' "$outputs_file" >/dev/null 2>&1; then
        print_error "instance_public_ips not found in Terraform outputs"
        print_info "Available outputs:"
        jq 'keys' "$outputs_file"
        exit 1
    fi

    local instance_ips=$(jq -r '.instance_public_ips.value | if type == "array" then .[] else . end' "$outputs_file" 2>&1 | grep -v '^null$' | grep -E '^[0-9]+\.')

    # Validate we have IPs
    if [ -z "$instance_ips" ]; then
        print_error "No valid instance IPs found in Terraform outputs"
        print_info "instance_public_ips value:"
        jq '.instance_public_ips' "$outputs_file"
        exit 1
    fi

    print_success "Found instance IPs:"
    echo "$instance_ips" | while read ip; do echo "  - $ip"; done

    # Extract SSH private key from Terraform outputs
    local ssh_key_file="$WORK_DIR/.deployer/ansible/${env}-ssh-key.pem"
    print_info "Extracting SSH private key..."
    cat "$outputs_file" | jq -r '.ssh_private_key.value' > "$ssh_key_file"
    chmod 600 "$ssh_key_file"
    print_success "SSH private key saved to: $ssh_key_file"

    cat > "$inventory_file" <<EOF
# Ansible inventory for $env
# Generated: $(date)

[app_servers]
$instance_ips

[app_servers:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=$ssh_key_file
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
EOF

    local host_count=$(echo "$instance_ips" | wc -l)
    print_success "Generated Ansible inventory with $host_count host(s)"
}
