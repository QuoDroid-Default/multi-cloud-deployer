#!/usr/bin/env bash

################################################################################
# Ansible helper functions
################################################################################

ansible_deploy() {
    local env=$1

    print_info "Deploying application with Ansible..."

    local playbook="$DEPLOYER_ROOT/ansible/playbooks/deploy-fullstack.yml"
    local inventory_file="$WORK_DIR/.deployer/ansible/${env}-inventory.ini"

    # Generate inventory from Terraform outputs
    generate_ansible_inventory "$env"

    # Run Ansible playbook
    cd "$DEPLOYER_ROOT/ansible"

    ANSIBLE_ROLES_PATH="$DEPLOYER_ROOT/ansible/roles" ansible-playbook \
        -i "$inventory_file" \
        "$playbook" \
        -e "env_name=$env" \
        -e "clone_dir=$CLONE_DIR" \
        -e "config_dir=$DEPLOYER_DIR"

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

    # Get EC2 instance public IPs from Terraform outputs
    print_info "Reading instance IPs from: $outputs_file"
    local instance_ips=$(cat "$outputs_file" | jq -r '.instance_public_ips.value | if type == "array" then .[] else . end' 2>/dev/null | grep -v '^null$' | tr '\n' ' ')

    # Validate we have IPs
    if [ -z "$instance_ips" ] || [ "$instance_ips" = " " ]; then
        print_error "No instance IPs found in Terraform outputs"
        print_info "Outputs file contains:"
        cat "$outputs_file" | jq '.instance_public_ips'
        exit 1
    fi

    print_success "Found instance IPs: $instance_ips"

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

    print_success "Generated Ansible inventory with $(echo $instance_ips | wc -w) hosts"
}
