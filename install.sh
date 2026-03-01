#!/usr/bin/env bash

################################################################################
# Multi-Cloud Deployer - Installation Script
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/your-org/multi-cloud-deployer/main/install.sh | bash
#
# Or:
#   wget -qO- https://raw.githubusercontent.com/your-org/multi-cloud-deployer/main/install.sh | bash
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO="https://github.com/your-org/multi-cloud-deployer.git"
INSTALL_DIR="${HOME}/.cloud-deploy"
BIN_DIR="${HOME}/.local/bin"

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }

print_header() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  Multi-Cloud Deployer - Installation Script                  ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

check_dependencies() {
    print_info "Checking dependencies..."

    local missing=()

    command -v git >/dev/null 2>&1 || missing+=("git")
    command -v terraform >/dev/null 2>&1 || missing+=("terraform")
    command -v ansible >/dev/null 2>&1 || missing+=("ansible")
    command -v yq >/dev/null 2>&1 || missing+=("yq")
    command -v jq >/dev/null 2>&1 || missing+=("jq")

    if [ ${#missing[@]} -gt 0 ]; then
        print_error "Missing required dependencies: ${missing[*]}"
        echo ""
        echo "Install missing dependencies:"
        echo "  macOS:   brew install ${missing[*]}"
        echo "  Ubuntu:  apt-get install ${missing[*]}"
        echo "  Fedora:  dnf install ${missing[*]}"
        echo ""
        exit 1
    fi

    print_success "All dependencies installed"
}

clone_repository() {
    print_info "Cloning multi-cloud-deployer..."

    if [ -d "$INSTALL_DIR" ]; then
        print_info "Updating existing installation..."
        cd "$INSTALL_DIR"
        git pull origin main
    else
        git clone "$REPO" "$INSTALL_DIR"
    fi

    print_success "Repository cloned to $INSTALL_DIR"
}

install_binary() {
    print_info "Installing cloud-deploy command..."

    mkdir -p "$BIN_DIR"

    # Create symlink to cloud-deploy script
    ln -sf "$INSTALL_DIR/cli/cloud-deploy" "$BIN_DIR/cloud-deploy"
    chmod +x "$BIN_DIR/cloud-deploy"

    print_success "Installed to $BIN_DIR/cloud-deploy"
}

configure_path() {
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        print_warning "Add $BIN_DIR to your PATH"
        echo ""
        echo "Add this to your ~/.bashrc or ~/.zshrc:"
        echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo ""
    else
        print_success "PATH already configured"
    fi
}

verify_installation() {
    print_info "Verifying installation..."

    export PATH="$BIN_DIR:$PATH"

    if command -v cloud-deploy >/dev/null 2>&1; then
        cloud-deploy --version
        print_success "Installation successful!"
    else
        print_error "Installation failed - cloud-deploy not found in PATH"
        exit 1
    fi
}

main() {
    print_header

    check_dependencies
    clone_repository
    install_binary
    configure_path
    verify_installation

    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  Installation Complete!                                       ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Add $BIN_DIR to your PATH (if not already)"
    echo "  2. Run: cloud-deploy --help"
    echo "  3. Configure your infrastructure repository"
    echo ""
    echo "Documentation:"
    echo "  https://github.com/your-org/multi-cloud-deployer"
}

main
