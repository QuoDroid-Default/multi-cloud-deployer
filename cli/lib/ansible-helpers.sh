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

    mkdir -p "$(dirname "$inventory_file")"

    # Get EC2 instance public IPs from Terraform outputs
    local instance_ips=$(terraform_output "$env" "instance_public_ips" 2>/dev/null | jq -r 'if type == "array" then .[] else . end' 2>/dev/null | tr '\n' ' ' || echo "")

    cat > "$inventory_file" <<EOF
# Ansible inventory for $env
# Generated: $(date)

[app_servers]
$instance_ips

[app_servers:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_python_interpreter=/usr/bin/python3
EOF

    print_success "Generated Ansible inventory"
}
