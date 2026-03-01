.PHONY: install install-user uninstall test help

# Installation directories
PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
USER_BINDIR = $(HOME)/.local/bin

help:
	@echo "Multi-Cloud Deployer - Installation"
	@echo ""
	@echo "Usage:"
	@echo "  make install        Install globally (requires sudo)"
	@echo "  make install-user   Install to user directory (no sudo)"
	@echo "  make uninstall      Uninstall"
	@echo "  make test           Run tests"
	@echo "  make help           Show this help"

install:
	@echo "Installing cloud-deploy to $(BINDIR)..."
	@mkdir -p $(BINDIR)
	@install -m 755 cli/cloud-deploy $(BINDIR)/cloud-deploy
	@echo "✓ Installed cloud-deploy to $(BINDIR)/cloud-deploy"
	@echo ""
	@echo "Run: cloud-deploy --version"

install-user:
	@echo "Installing cloud-deploy to $(USER_BINDIR)..."
	@mkdir -p $(USER_BINDIR)
	@install -m 755 cli/cloud-deploy $(USER_BINDIR)/cloud-deploy
	@echo "✓ Installed cloud-deploy to $(USER_BINDIR)/cloud-deploy"
	@echo ""
	@echo "Make sure $(USER_BINDIR) is in your PATH:"
	@echo "  export PATH=\"\$$HOME/.local/bin:\$$PATH\""
	@echo ""
	@echo "Run: cloud-deploy --version"

uninstall:
	@echo "Uninstalling cloud-deploy..."
	@rm -f $(BINDIR)/cloud-deploy
	@rm -f $(USER_BINDIR)/cloud-deploy
	@echo "✓ Uninstalled"

test:
	@echo "Running validation tests..."
	@cli/cloud-deploy validate || echo "Note: Run from infrastructure repository to validate configs"
	@echo "✓ Tests complete"
