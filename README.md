# Multi-Cloud Deployer

Reusable infrastructure automation for deploying applications to AWS and Azure with zero manual configuration.

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/your-org/multi-cloud-deployer/releases)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Features

- 🌍 **Multi-Cloud** - Deploy to AWS or Azure using the same configuration
- 🚀 **Zero Config** - Predefined size presets (small, medium, large, xlarge)
- 🔄 **Reusable** - Use for any Django, Node.js, or React application
- 📦 **Complete Stack** - Compute, database, cache, storage, networking, CDN
- 🔐 **Security First** - AWS Secrets Manager, Azure Key Vault integration
- 📊 **Infrastructure as Code** - Terraform modules + Ansible roles
- 🎯 **GitOps Ready** - Works with GitHub Actions, GitLab CI, ArgoCD

## Quick Start

### Installation

```bash
# One-line install
curl -sSL https://raw.githubusercontent.com/your-org/multi-cloud-deployer/main/install.sh | bash

# Or manual install
git clone https://github.com/your-org/multi-cloud-deployer.git
cd multi-cloud-deployer
make install
```

### Usage

```bash
# From your infrastructure repository
cd coco-testai-infrastructure

# Deploy to production
cloud-deploy create prod
cloud-deploy up prod

# Check status
cloud-deploy status prod

# Scale instances
cloud-deploy scale prod --instances 4

# Rollback
cloud-deploy rollback prod --to-version v1.2.3

# Destroy environment
cloud-deploy down prod
```

## Architecture

### Repository Structure

This system uses a **separate repository pattern**:

```
multi-cloud-deployer/           # THIS REPOSITORY (reusable)
├── terraform/modules/          # Infrastructure modules
├── ansible/roles/              # Configuration roles
├── cli/                        # Deployment CLI
└── docs/                       # Documentation

your-app-infrastructure/        # YOUR INFRASTRUCTURE REPO
├── .deployer/
│   ├── config.yaml             # Project configuration
│   ├── repos.yaml              # FE/BE repository references
│   └── environments/
│       ├── prod.yaml
│       └── demo.yaml

your-app-backend/               # YOUR BACKEND REPO
your-app-frontend/              # YOUR FRONTEND REPO
```

### How It Works

1. **Install `cloud-deploy` globally** - One-time installation
2. **Create infrastructure repository** - Contains .deployer/ configs
3. **Reference your application repos** - via repos.yaml
4. **Run `cloud-deploy up <env>`** - Deploys everything

The CLI automatically:
- Clones backend and frontend repositories
- Builds frontend (npm run build)
- Provisions infrastructure (Terraform)
- Deploys applications (Ansible)
- Configures services (systemd, nginx)

## Configuration

### Project Configuration

**File: `.deployer/config.yaml`**

```yaml
project:
  name: "my-app"
  type: "fullstack"

components:
  backend:
    type: "python-django"
    python_version: "3.10"
    services:
      - name: "daphne"
        type: "asgi"
        port: 8000

  webapp:
    type: "react-vite"
    node_version: "20"
    build_command: "npm run build"

infrastructure:
  database:
    engine: "postgres"
    version: "15.4"
  cache:
    engine: "redis"
```

### Repository References

**File: `.deployer/repos.yaml`**

```yaml
version: "1.0"

repositories:
  backend:
    url: "https://github.com/your-org/my-app-backend.git"
    type: "python-django"
    branch: "main"

  frontend:
    url: "https://github.com/your-org/my-app-frontend.git"
    type: "react-vite"
    branch: "main"
```

### Environment Configuration

**File: `.deployer/environments/prod.yaml`**

```yaml
environment: prod
cloud_provider: aws
region: us-east-1
size_preset: large

# Pin production to stable releases
repositories:
  backend:
    ref: "v1.5.2"
  frontend:
    ref: "v2.1.0"

domain:
  webapp: "app.example.com"
  api: "api.example.com"

infrastructure:
  database:
    multi_az: true
    backup_retention_days: 30
  compute:
    autoscaling:
      enabled: true
      min_instances: 2
      max_instances: 6
```

## Size Presets

Pre-configured infrastructure sizes for cost optimization:

| Preset | Monthly Cost | Use Case | Compute | Database | Cache |
|--------|-------------|----------|---------|----------|-------|
| **small** | $80-100 | Development/Test | t3.medium | db.t3.micro | cache.t3.micro |
| **medium** | $200-250 | Staging/Demo | t3.large x2 | db.t3.small | cache.t3.small |
| **large** | $500-600 | Production | m5.xlarge x3 | db.m5.large | cache.m5.large |
| **xlarge** | $1200-1500 | Enterprise | m5.2xlarge x5 | db.m5.2xlarge | cache.m5.xlarge |

See [cli/config/size-presets.yaml](cli/config/size-presets.yaml) for full specifications.

## Supported Stacks

### Backend Frameworks
- ✅ Python/Django (with Celery, Daphne, etc.)
- ✅ Node.js/Express
- 🚧 Ruby/Rails (coming soon)
- 🚧 Java/Spring (coming soon)

### Frontend Frameworks
- ✅ React (Vite)
- ✅ React (Create React App)
- 🚧 Vue.js (coming soon)
- 🚧 Angular (coming soon)

### Infrastructure
- ✅ AWS (EC2, RDS, ElastiCache, S3, VPC)
- ✅ Azure (VMs, PostgreSQL, Redis, Blob Storage, VNet)
- ✅ PostgreSQL, MySQL, MariaDB
- ✅ Redis, Memcached
- ✅ Nginx reverse proxy
- ✅ Let's Encrypt SSL
- ✅ CloudFront/Azure CDN

## Examples

See [examples/](examples/) directory for complete examples:

- [examples/django-fullstack/](examples/django-fullstack/) - Django + React fullstack app
- [examples/nodejs-api/](examples/nodejs-api/) - Node.js API server
- [examples/react-spa/](examples/react-spa/) - React SPA with CDN

## Documentation

- [QUICKSTART.md](docs/QUICKSTART.md) - Get started in 5 minutes
- [CONFIGURATION.md](docs/CONFIGURATION.md) - Complete configuration guide
- [DEPLOYMENT_AUTOMATION_PLAN.md](docs/DEPLOYMENT_AUTOMATION_PLAN.md) - Architecture deep dive
- [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Common issues and solutions

## Requirements

- Terraform >= 1.6
- Ansible >= 2.15
- yq >= 4.30
- jq >= 1.6
- AWS CLI v2 (for AWS deployments)
- Azure CLI (for Azure deployments)

## Contributing

Contributions welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT License - see [LICENSE](LICENSE) file.

## Support

- GitHub Issues: https://github.com/your-org/multi-cloud-deployer/issues
- Documentation: https://github.com/your-org/multi-cloud-deployer
- Discussions: https://github.com/your-org/multi-cloud-deployer/discussions

---

**Built with ❤️ for the DevOps community**
