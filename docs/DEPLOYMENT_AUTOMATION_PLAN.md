# Multi-Cloud Deployment System
## Reusable Infrastructure Automation for Any Application

**Date:** March 1, 2026
**Version:** 2.1
**Status:** Design Phase
**Architecture:** Separate Repository Pattern with Global CLI (2026 Best Practice)

---

## Changelog

### Version 2.1 (March 1, 2026)
- ✅ **Global CLI installation** - Install once, use everywhere (`cloud-deploy` command)
- ✅ **4-repository architecture** - Support for separate frontend/backend repos
- ✅ **Repository references** - New `repos.yaml` file to reference FE/BE repos
- ✅ **Environment-specific refs** - Deploy different versions to different environments
- ✅ **Simplified workflow** - No need to manually clone FE/BE repos
- ✅ **Updated examples** - Both monorepo and multi-repo examples

### Version 2.0 (February 28, 2026)
- ✅ **Separate repository pattern** - Reusable deployer + application configs
- ✅ **External YAML configuration** - Industry-standard approach
- ✅ **Size presets** - Predefined small/medium/large configurations
- ✅ **Independent versioning** - Deployer and applications versioned separately

### Version 1.0 (February 27, 2026)
- Initial design with Terraform + Ansible
- Basic AWS and Azure support

---

## Executive Summary

This document outlines a **reusable, cloud-agnostic deployment automation system** that supports both AWS and Azure with minimal manual intervention. The system is designed as a **separate repository with global CLI** following 2026 industry best practices for reusable infrastructure modules.

**Architecture Pattern: Separate Repository with Global CLI**

Following [HashiCorp](https://developer.hashicorp.com/terraform/tutorials/modules/pattern-module-creation) and [AWS best practices](https://docs.aws.amazon.com/prescriptive-guidance/latest/terraform-aws-provider-best-practices/structure.html):

1. **`multi-cloud-deployer`** - Reusable deployment system (installed globally)
2. **`{app}-infrastructure`** - Deployment configuration (references application repos)
3. **`{app}-backend`** - Backend application code (referenced via repos.yaml)
4. **`{app}-webapp`** - Frontend application code (referenced via repos.yaml)

**For Coco TestAI specifically:**
- `multi-cloud-deployer` - Global CLI tool
- `coco-testai-infrastructure` - Deployment configs (.deployer/config.yaml, repos.yaml, environments/)
- `coco-testai-backend` - Django application
- `coco-testai-webapp` - React application

**Built Following 2026 Industry Standards:**
- ✅ **Separate repository pattern** (HashiCorp/AWS standard for reusable modules)
- ✅ **External YAML configuration** (Kubernetes/AWS CloudFormation pattern)
- ✅ **JSON Schema validation** (pre-deployment error detection)
- ✅ **GitOps workflows** (Atlantis/ArgoCD compatible)
- ✅ **DRY principle** (Terragrunt/Terramate philosophy)
- ✅ **Security-first** (AWS Secrets Manager, no hardcoded secrets)
- ✅ **IDE integration** (VSCode/IntelliJ YAML support)
- ✅ **Independent versioning** (v1.0, v1.1 releases)

**Key Goals:**
1. **Reusable across multiple projects** - Use for any Django/Node.js/React application
2. Deploy webapp and backend to VM instances (EC2/Azure VM) with zero manual steps
3. Switch between AWS and Azure using configuration only
4. Support unlimited environments (prod, demo, test, uat, staging, feature branches, etc.)
5. Easy environment lifecycle management (create, deploy, destroy via CLI or GitHub Actions)
6. Independent versioning and maintenance from application code
7. Automated scaling, monitoring, and rollback capabilities

**Use Cases:**
- Coco TestAI (Django + React + Chrome Extension)
- Future Django applications
- Node.js/React applications
- Any fullstack application with standard architecture

---

## Repository Architecture

### Separate Repository Pattern (2026 Best Practice)

Following industry standards ([HashiCorp Module Pattern](https://developer.hashicorp.com/terraform/tutorials/modules/pattern-module-creation), [AWS Terraform Guidance](https://docs.aws.amazon.com/prescriptive-guidance/latest/terraform-aws-provider-best-practices/structure.html)), this deployment system uses a **separate repository architecture** with **global CLI installation** for maximum reusability and simplicity.

**For applications with separate frontend/backend repositories** (like Coco TestAI), the recommended architecture uses **4 repositories**:
1. `multi-cloud-deployer` - Reusable deployment system (global CLI)
2. `coco-testai-infrastructure` - Deployment configuration (references FE/BE)
3. `coco-testai-backend` - Backend application code
4. `coco-testai-webapp` - Frontend application code

#### Repository 1: `multi-cloud-deployer` (Infrastructure System)

**Purpose:** Reusable deployment automation
**Contains:** Terraform modules, Ansible roles, CLI tools, configuration templates
**Versioned:** Independent releases (v1.0, v1.1, v2.0)
**Maintained by:** DevOps/Platform team
**Reusable:** Yes - for multiple applications

```
multi-cloud-deployer/                    # THIS REPOSITORY
├── terraform/
│   └── modules/
│       ├── compute/                     # Generic EC2/Azure VM module
│       ├── database/                    # Generic RDS/PostgreSQL module
│       ├── cache/                       # Generic Redis module
│       ├── storage/                     # Generic S3/Blob module
│       ├── network/                     # Generic VPC/VNet module
│       ├── cdn/                         # Generic CloudFront/Azure CDN
│       └── dns/                         # Generic Route53/Azure DNS
│
├── ansible/
│   ├── playbooks/
│   │   ├── deploy-webapp.yml            # Generic webapp deployment
│   │   ├── deploy-backend.yml           # Generic backend deployment
│   │   └── rollback.yml                 # Generic rollback
│   └── roles/
│       ├── nodejs/                      # Node.js setup
│       ├── python-django/               # Django setup
│       ├── nginx/                       # Nginx configuration
│       └── docker/                      # Docker-based apps
│
├── cli/
│   ├── deploy.sh                        # Main CLI tool
│   ├── config/
│   │   ├── size-presets.yaml            # Cloud-agnostic size presets
│   │   └── schemas/
│   │       ├── project-config-schema.json
│   │       └── environment-schema.json
│   └── lib/
│       ├── aws-helpers.sh
│       ├── azure-helpers.sh
│       └── terraform-helpers.sh
│
├── .github/
│   └── workflows/
│       └── deploy-action.yml            # Reusable GitHub Action
│
├── examples/
│   ├── django-fullstack/                # Example: Django + React
│   ├── nodejs-api/                      # Example: Node.js API
│   └── react-spa/                       # Example: React SPA
│
├── docs/
│   ├── README.md
│   ├── QUICKSTART.md
│   ├── CONFIGURATION.md
│   └── DEPLOYMENT_AUTOMATION_PLAN.md    # This document
│
├── LICENSE
└── README.md
```

#### Repository 2: `coco-testai-infrastructure` (Deployment Configuration)

**Purpose:** Deployment configuration for Coco TestAI
**Contains:** Environment configs, secrets references, deployment workflows
**Versioned:** Independent from application (v1.0, v1.1)
**Maintained by:** DevOps/Platform team
**Uses:** `multi-cloud-deployer` as global CLI

```
coco-testai-infrastructure/              # INFRASTRUCTURE REPOSITORY
├── .deployer/
│   ├── config.yaml                      # Project configuration
│   ├── repos.yaml                       # 🆕 References to FE/BE repos
│   └── environments/
│       ├── prod.yaml                    # Production environment
│       ├── demo.yaml                    # Demo environment
│       └── test.yaml                    # Test environment
│
├── .github/
│   └── workflows/
│       ├── deploy-prod.yml              # Production deployment
│       ├── deploy-demo.yml              # Demo deployment
│       └── destroy.yml                  # Environment cleanup
│
├── terraform/
│   └── backend-config/                  # Remote state configuration
│       ├── prod.tfbackend
│       └── demo.tfbackend
│
├── docs/
│   └── DEPLOYMENT.md
│
└── README.md
```

#### Repository 3: `coco-testai-backend` (Backend Application)

**Purpose:** Django backend application
**Contains:** Backend code only
**Versioned:** Application releases (v1.0, v1.1)
**Maintained by:** Backend team

```
coco-testai-backend/                     # BACKEND REPOSITORY
├── interpreter/
│   ├── services/
│   ├── views.py
│   └── ...
├── requirements.txt
├── manage.py
├── .github/
│   └── workflows/
│       └── tests.yml                    # Backend tests only
└── README.md
```

#### Repository 4: `coco-testai-webapp` (Frontend Application)

**Purpose:** React frontend application
**Contains:** Frontend code only
**Versioned:** Application releases (v1.0, v1.1)
**Maintained by:** Frontend team

```
coco-testai-webapp/                      # FRONTEND REPOSITORY
├── src/
│   ├── components/
│   ├── App.jsx
│   └── ...
├── package.json
├── vite.config.js
├── .github/
│   └── workflows/
│       └── tests.yml                    # Frontend tests only
└── README.md
```

### How They Work Together

**Relationship:**
```
coco-testai-infrastructure repository
    ↓ references (via repos.yaml)
coco-testai-backend + coco-testai-webapp
    ↓ uses (global CLI)
multi-cloud-deployer (installed globally)
    ↓ provides
Terraform modules + Ansible roles + CLI tools
    ↓ deploys to
AWS/Azure infrastructure
```

### Global CLI Installation (One-Time Setup)

The `multi-cloud-deployer` is installed **once globally** on your system, similar to tools like `docker`, `kubectl`, or `terraform`. Once installed, the `cloud-deploy` command works from any directory.

**Installation Methods:**

**Option 1: Install Script (Recommended)**
```bash
# One-line installation
curl -sSL https://raw.githubusercontent.com/your-org/multi-cloud-deployer/main/install.sh | bash

# Verifies dependencies (terraform, ansible, yq, jq, etc.)
# Installs to /usr/local/bin/cloud-deploy
# Adds shell completion (bash/zsh)
```

**Option 2: Manual Installation**
```bash
# Clone the repository
git clone https://github.com/your-org/multi-cloud-deployer.git ~/tools/multi-cloud-deployer
cd ~/tools/multi-cloud-deployer

# Install globally (requires sudo)
sudo make install

# Or install to user directory (no sudo)
make install-user
# This installs to ~/.local/bin/cloud-deploy
# Add to PATH: export PATH="$HOME/.local/bin:$PATH"
```

**Option 3: Package Manager (Future)**
```bash
# Once published to package managers
brew install cloud-deploy           # macOS
apt-get install cloud-deploy        # Ubuntu/Debian
choco install cloud-deploy          # Windows
```

**Verify Installation:**
```bash
cloud-deploy --version
# Output: cloud-deploy v1.0.0 (multi-cloud-deployer)

cloud-deploy --help
# Shows available commands and options
```

**Benefits of Global Installation:**
- ✅ Install once, use everywhere
- ✅ Works from any directory
- ✅ Consistent across all projects
- ✅ Easy to update: `cloud-deploy update` or `make update`
- ✅ No per-project setup required

**Deployment Workflow:**
```bash
# 1. Clone infrastructure repository
git clone https://github.com/your-org/coco-testai-infrastructure.git
cd coco-testai-infrastructure

# 2. Deploy to production (CLI auto-clones FE/BE repos from repos.yaml)
cloud-deploy create prod

# 3. Deploy application code
cloud-deploy up prod

# 4. Check status
cloud-deploy status prod

# 5. Rollback if needed
cloud-deploy rollback prod --to-version v1.2.3
```

**What Happens During Deployment:**

```
┌─────────────────────────────────────────────────────────────────────┐
│  Developer runs: cloud-deploy up prod                               │
│  (from coco-testai-infrastructure/ directory)                       │
└─────────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────────┐
│  Step 1: Read Configuration Files                                   │
│  • .deployer/config.yaml (project config)                           │
│  • .deployer/repos.yaml (FE/BE repo references)                     │
│  • .deployer/environments/prod.yaml (environment config)            │
└─────────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────────┐
│  Step 2: Clone Application Repositories                             │
│  • git clone coco-testai-backend (to /tmp/cloud-deploy-xxx/)       │
│  • git clone coco-testai-webapp (to /tmp/cloud-deploy-xxx/)        │
│  • git checkout v1.5.2 (backend) and v2.1.0 (frontend)             │
└─────────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────────┐
│  Step 3: Build Application Code                                     │
│  • Frontend: npm install && npm run build                           │
│  • Backend: pip install -r requirements.txt                         │
└─────────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────────┐
│  Step 4: Provision Infrastructure (Terraform)                       │
│  • Create VPC, subnets, security groups                             │
│  • Launch EC2 instances (m5.2xlarge)                                │
│  • Provision RDS PostgreSQL (db.m5.large)                           │
│  • Provision ElastiCache Redis (cache.m5.large)                     │
│  • Create S3 buckets, CloudFront distribution                       │
│  • Configure Route53 DNS (app.cocotestai.com)                       │
└─────────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────────┐
│  Step 5: Configure Servers (Ansible)                                │
│  • Install Python, Node.js, Nginx, Docker                           │
│  • Deploy backend code to EC2                                       │
│  • Deploy frontend build to S3 + CloudFront                         │
│  • Configure systemd services (daphne, celery, grpc, etc.)          │
│  • Fetch secrets from AWS Secrets Manager                           │
│  • Start all services                                               │
└─────────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────────┐
│  Step 6: Verify Deployment                                          │
│  • Health check: https://api.cocotestai.com/api/health/             │
│  • Run smoke tests                                                  │
│  • Report deployment status                                         │
└─────────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────────┐
│  Step 7: Cleanup                                                    │
│  • Remove temporary clones (/tmp/cloud-deploy-xxx/)                 │
│  • Save deployment logs                                             │
│  • Output deployment URL and credentials                            │
└─────────────────────────────────────────────────────────────────────┘
                              ↓
                      ✅ Deployment Complete!
                  https://app.cocotestai.com
```

### Benefits of Separate Repository Architecture

Following [Spacelift Terraform Best Practices](https://spacelift.io/blog/terraform-best-practices):

**✅ Reusability:**
- Use `multi-cloud-deployer` for any application (Django, Node.js, React, etc.)
- Install once globally, deploy anywhere
- One tool, unlimited projects

**✅ Independent Versioning:**
- Deployer: v1.0, v1.1, v2.0
- Infrastructure configs: independent versioning
- Backend & Frontend: separate release cycles
- Pin infrastructure to specific deployer versions

**✅ Clear Ownership:**
- DevOps team owns `multi-cloud-deployer` + `coco-testai-infrastructure`
- Backend team owns `coco-testai-backend`
- Frontend team owns `coco-testai-webapp`
- Different RBAC permissions per repository

**✅ Faster Development:**
- Update deployer without touching application code
- Backend and frontend teams work independently
- Infrastructure changes don't trigger application builds
- Test deployer changes independently
- Roll out deployer updates to all projects

**✅ Security Best Practice:**
- Production secrets stay in infrastructure repo (separate access control)
- Application code doesn't contain deployment secrets
- Deployer can be open sourced without exposing configurations

**✅ Open Source Potential:**
- Can make `multi-cloud-deployer` public
- Keep application code and configs private
- Community contributions to deployer
- Share infrastructure automation with other teams/companies

**✅ Simplicity for Developers:**
- Backend/frontend teams don't need to know Terraform/Ansible
- Global CLI works from any directory
- Single command deployment: `cloud-deploy up prod`

### Referencing Separate FE/BE Repositories

For applications with separate frontend and backend repositories, the infrastructure repository uses a `repos.yaml` file to reference application code.

**File: `.deployer/repos.yaml`**
```yaml
# References to application repositories
version: "1.0"

repositories:
  backend:
    url: "https://github.com/your-org/coco-testai-backend.git"
    type: "python-django"
    branch: "main"                    # Default branch for deployments

    # Optional: Use SSH for private repos
    # url: "git@github.com:your-org/coco-testai-backend.git"

    # Optional: Pin to specific commit/tag for production
    # ref: "v1.2.3"                   # Git tag
    # ref: "abc123def"                # Git commit hash

  frontend:
    url: "https://github.com/your-org/coco-testai-webapp.git"
    type: "react-vite"
    branch: "main"

  # Optional: Chrome extension or other components
  extension:
    url: "https://github.com/your-org/coco-testai-chrome-extension.git"
    type: "chrome-extension"
    branch: "main"
    deploy: false                     # Don't deploy to servers (publish to Chrome Web Store separately)
```

**How CLI Uses This:**
```bash
# When you run:
cloud-deploy up prod

# The CLI:
# 1. Reads .deployer/repos.yaml
# 2. Clones backend and frontend to /tmp/cloud-deploy-{timestamp}/
# 3. Checks out the specified branch/ref
# 4. Builds frontend (npm run build)
# 5. Deploys backend + built frontend to servers
# 6. Cleans up temporary clones
```

**Environment-Specific Overrides:**

You can override repository refs per environment:

**File: `.deployer/environments/prod.yaml`**
```yaml
environment: prod
cloud: aws
region: us-east-1
size_preset: large

# Override repository refs for production
repositories:
  backend:
    ref: "v1.5.2"                     # Production uses stable release
  frontend:
    ref: "v2.1.0"                     # Frontend can be different version

# ... rest of config
```

**File: `.deployer/environments/demo.yaml`**
```yaml
environment: demo
cloud: aws
region: us-east-1
size_preset: small

# Demo environment uses latest from develop branch
repositories:
  backend:
    branch: "develop"                 # Latest development code
  frontend:
    branch: "develop"

# ... rest of config
```

**Benefits:**
- ✅ Backend and frontend repos stay completely independent
- ✅ Different teams can work on different repos with separate permissions
- ✅ Deploy different versions of backend/frontend to different environments
- ✅ Pin production to stable releases while demo uses latest code
- ✅ No need to coordinate version numbers between FE/BE
- ✅ Infrastructure team manages deployment config, not application teams

---

## Current State Analysis

### Backend (Django/Python Application)

**Technology Stack:**
- Python 3.10+
- Django 4.2.27
- PostgreSQL (database)
- Redis (caching, WebSocket, Celery broker)
- Nginx (reverse proxy)
- Daphne ASGI server (WebSocket support)
- Celery (background tasks)
- Minikube/Kubernetes (test execution environment)

**Required Services (7 systemd services):**
1. `coco-daphne.service` - ASGI server for WebSocket + HTTP
2. `coco-grpc-agent.service` - gRPC service for Claude AI
3. `coco-celery-worker.service` - Background task worker
4. `coco-celery-beat.service` - Periodic task scheduler
5. `coco-pg-listener.service` - PostgreSQL LISTEN/NOTIFY handler
6. `coco-minikube.service` - Kubernetes for test execution
7. `nginx.service` - Reverse proxy

**Infrastructure Requirements:**
- PostgreSQL server (or RDS/Azure Database)
- Redis server (or ElastiCache/Azure Cache)
- S3-compatible storage (artifacts, test results)
- Container registry (for test executor images)
- Load balancer (for multi-instance deployments)
- SSL certificates (Let's Encrypt or cloud provider)

**Current Deployment:**
- Systemd services on EC2 instance
- Manual deployment via SSH
- Environment variables in `.env` files
- No containerization currently

### Webapp (React/Vite Application)

**Technology Stack:**
- React 19
- Vite 7
- Node.js 20
- React Router 7 (SPA routing)

**Build Output:**
- Static files in `dist/` folder
- Hash-named assets for cache busting
- Entry point: `index.html`

**Current Deployment:**
- GitHub Actions workflow
- S3 bucket + CloudFront CDN
- Environments: test, demo, prod
- Automated on push to respective branches

**Infrastructure Requirements:**
- Static file hosting (S3/Azure Blob Storage)
- CDN (CloudFront/Azure CDN)
- SSL certificates
- SPA routing configuration (404 → index.html)

### Chrome Extension

**Status:** Not deployed to cloud (distributed via Chrome Web Store)
**Deployment:** Manual package and upload
**Future Enhancement:** Automate packaging in CI/CD

---

## Project Configuration (Coco TestAI Example)

This section shows how Coco TestAI configures itself to use the `multi-cloud-deployer` system.

### Configuration Files in Infrastructure Repository

**File: `coco-testai-infrastructure/.deployer/config.yaml`**

```yaml
# Project configuration for multi-cloud-deployer
# This file defines HOW Coco TestAI should be deployed

project:
  name: "coco-testai"
  type: "fullstack"                     # webapp, backend, fullstack
  description: "AI-powered test case generation platform"

components:
  backend:
    type: "python-django"
    # No path needed - repos.yaml specifies the repository
    python_version: "3.10"
    requirements_file: "requirements.txt"
    root_dir: "."                       # Root of the backend repo

    services:
      - name: "daphne"
        type: "asgi"
        port: 8000
        command: "daphne -b 0.0.0.0 -p 8000 coco_testai.asgi:application"

      - name: "grpc-agent"
        type: "grpc"
        port: 50051
        command: "python grpc_agent.py"

      - name: "celery-worker"
        type: "celery-worker"
        concurrency: 4
        command: "celery -A coco_testai worker --loglevel=info"

      - name: "celery-beat"
        type: "celery-beat"
        command: "celery -A coco_testai beat --loglevel=info"

      - name: "pg-listener"
        type: "custom"
        command: "python manage.py run_pg_listener"

  webapp:
    type: "react-vite"
    # No path needed - repos.yaml specifies the repository
    node_version: "20"
    package_manager: "npm"
    build_command: "npm run build"
    build_output: "dist"
    root_dir: "."                       # Root of the frontend repo
    env_file: ".env.production"

  extension:
    type: "chrome-extension"
    # No path needed - repos.yaml specifies the repository
    deploy_to_cloud: false              # Chrome Web Store only
    build_command: "npm run build"
    build_output: "dist"
    root_dir: "."

infrastructure:
  database:
    engine: "postgres"
    version: "15.4"
    name: "coco_testai"
    port: 5432

  cache:
    engine: "redis"
    version: "7.0"
    port: 6379

  storage:
    type: "s3"                          # or "azure-blob"
    buckets:
      - name: "artifacts"
        purpose: "Test artifacts and execution results"
      - name: "static"
        purpose: "Django static files"

  kubernetes:
    enabled: true
    type: "minikube"                    # or "eks", "aks"
    purpose: "test-execution"
    namespace: "test-runners"

secrets:
  provider: "aws-secrets-manager"       # or "azure-key-vault"
  prefix: "coco-testai"                 # Namespace: coco-testai/{env}/{secret}

  required:
    - name: "DJANGO_SECRET_KEY"
      description: "Django secret key for cryptographic signing"

    - name: "DODO_PAYMENTS_API_KEY"
      description: "Dodo Payments API key for billing"

    - name: "DODO_WEBHOOK_SECRET"
      description: "Dodo Payments webhook signing secret"

    - name: "ANTHROPIC_API_KEY"
      description: "Claude API key for AI features"

    - name: "GOOGLE_OAUTH_CLIENT_ID"
      description: "Google OAuth client ID"

    - name: "GOOGLE_OAUTH_CLIENT_SECRET"
      description: "Google OAuth client secret"

    - name: "GITHUB_OAUTH_CLIENT_ID"
      description: "GitHub OAuth client ID"

    - name: "GITHUB_OAUTH_CLIENT_SECRET"
      description: "GitHub OAuth client secret"

monitoring:
  health_endpoints:
    backend: "/api/health/"
    metrics: "/api/metrics/"

  alerts:
    - type: "error_rate"
      threshold: 5                      # percent
      window: "5m"

    - type: "response_time"
      threshold: 2000                   # milliseconds (p95)
      window: "5m"

  logging:
    level: "INFO"                       # DEBUG, INFO, WARNING, ERROR
    destination: "cloudwatch"           # or "azure-monitor"
```

**File: `coco-testai-infrastructure/.deployer/environments/prod.yaml`**

```yaml
# Production environment configuration

environment: "prod"
cloud_provider: "aws"
region: "us-east-1"

# Reference size preset from multi-cloud-deployer
size_preset: "large"                    # Uses presets from deployer repo

# Domain configuration
domain:
  root: "cocotestai.com"
  webapp: "app.cocotestai.com"
  api: "api.cocotestai.com"

  ssl:
    provider: "acm"                     # or "letsencrypt"
    auto_renew: true

# Override specific infrastructure settings
infrastructure:
  database:
    backup_retention_days: 30
    multi_az: true
    storage_encrypted: true

  cache:
    automatic_failover: true
    num_cache_nodes: 2

  compute:
    autoscaling:
      enabled: true
      min_instances: 2
      max_instances: 6
      target_cpu: 70

# Environment-specific tags
tags:
  Environment: "Production"
  CostCenter: "Engineering"
  Owner: "DevOps Team"
  Compliance: "SOC2"
  DataClassification: "Confidential"
```

**File: `coco-testai-infrastructure/.deployer/environments/demo.yaml`**

```yaml
# Demo environment configuration

environment: "demo"
cloud_provider: "aws"
region: "us-east-1"

size_preset: "medium"                   # Smaller than prod

domain:
  root: "cocotestai.com"
  webapp: "demo.cocotestai.com"
  api: "api-demo.cocotestai.com"

infrastructure:
  database:
    backup_retention_days: 7
    multi_az: false                     # Single AZ for cost savings

  compute:
    autoscaling:
      enabled: false                    # Fixed instances

tags:
  Environment: "Demo"
  CostCenter: "Marketing"
  Purpose: "Customer Demonstrations"
```

### How Deployment System Reads Configuration

When you run `cloud-deploy up prod` from `coco-testai-infrastructure/`, the deployer:

1. **Reads repository references** (`.deployer/repos.yaml`)
   - Finds backend repo: `github.com/your-org/coco-testai-backend`
   - Finds frontend repo: `github.com/your-org/coco-testai-webapp`
   - Clones repos to temporary directory: `/tmp/cloud-deploy-{timestamp}/`
   - Checks out specified branch/tag (e.g., `v1.5.2` for prod)

2. **Reads project config** (`.deployer/config.yaml`)
   - Identifies it's a Django + React fullstack app
   - Loads required services (daphne, celery, grpc, etc.)
   - Identifies infrastructure needs (PostgreSQL, Redis, S3, Kubernetes)

3. **Reads environment config** (`.deployer/environments/prod.yaml`)
   - Loads size preset "large" from deployer's `cli/config/size-presets.yaml`
   - Gets instance types: m5.2xlarge, db.m5.large, cache.m5.large
   - Applies environment-specific overrides (autoscaling, multi-AZ, etc.)
   - Applies repository ref overrides (if specified in environment)

4. **Generates Terraform configuration**
   - Creates environment-specific terraform.tfvars
   - References reusable modules from deployer repo
   - Applies tags, security settings, networking

5. **Runs Terraform**
   - Provisions infrastructure (EC2, RDS, Redis, S3, VPC, etc.)
   - Outputs connection details (DB endpoint, Redis endpoint, S3 buckets)

6. **Builds application code**
   - Builds frontend: `cd /tmp/.../coco-testai-webapp && npm run build`
   - Prepares backend: `cd /tmp/.../coco-testai-backend && pip install -r requirements.txt`

7. **Runs Ansible**
   - Uses `python-django` role from deployer
   - Deploys backend code to EC2 instances
   - Configures all 5 systemd services
   - Deploys built webapp to S3 + CloudFront

8. **Verifies deployment**
   - Checks health endpoint: `https://api.cocotestai.com/api/health/`
   - Runs smoke tests
   - Reports success/failure

9. **Cleanup**
   - Removes temporary clones: `/tmp/cloud-deploy-{timestamp}/`
   - Keeps deployment logs for troubleshooting

### Using the Deployment System

```bash
# Install deployer globally (one-time setup)
curl -sSL https://raw.githubusercontent.com/your-org/multi-cloud-deployer/main/install.sh | bash

# Verify installation
cloud-deploy --version
# Output: multi-cloud-deployer v1.0.0

# From coco-testai-infrastructure repository
cd coco-testai-infrastructure

# Create production environment (reads .deployer/config.yaml and environments/prod.yaml)
cloud-deploy create prod

# Deploy application (clones FE/BE repos from repos.yaml, builds, and deploys)
cloud-deploy up prod

# Check status
cloud-deploy status prod

# View logs
cloud-deploy logs prod --component backend --service daphne

# Scale up
cloud-deploy scale prod --instances 4

# Rollback
cloud-deploy rollback prod --to-version v1.2.3

# Destroy environment
cloud-deploy down prod
```

---

## Prerequisites

### 1. Development Tools

**Required on CI/CD Runner:**
- Terraform >= 1.6
- Ansible >= 2.15
- Docker >= 24.0
- kubectl >= 1.28
- AWS CLI v2
- Azure CLI
- Node.js 20 LTS
- Python 3.10+
- yq >= 4.30 (YAML processor - industry standard for config management)
- jq >= 1.6 (JSON processor)

**Required on Developer Machine:**
- Git
- Terraform
- Ansible (optional, for manual runs)
- Cloud provider CLI tools
- yq (YAML processor for CLI tool)
- jq (JSON processor)

**Installing yq and jq:**

```bash
# macOS (Homebrew)
brew install yq jq

# Ubuntu/Debian
sudo apt-get update
sudo apt-get install yq jq

# Windows (Chocolatey)
choco install yq jq

# Or download binaries directly:
# yq: https://github.com/mikefarah/yq/releases
# jq: https://stedolan.github.io/jq/download/

# Verify installation
yq --version    # Should show v4.30 or higher
jq --version    # Should show 1.6 or higher
```

**Why yq and jq?**
- **yq** - Industry standard YAML processor (used by Kubernetes, Helm, AWS)
- **jq** - De facto standard JSON processor (used universally in DevOps)
- **Alternative** - Python fallback included in scripts if tools not available

### 2. Cloud Provider Accounts

**AWS Requirements:**
- AWS Account with admin or deployment IAM user
- Access Key ID + Secret Access Key
- S3 bucket for Terraform state (or Terraform Cloud)
- Route53 hosted zone (if using custom domain)
- ACM certificate for SSL (or Let's Encrypt)

**Azure Requirements:**
- Azure Subscription with Contributor role
- Service Principal credentials (tenant ID, client ID, secret)
- Azure Storage Account for Terraform state
- Azure DNS zone (if using custom domain)
- Azure Key Vault for secrets

### 3. Third-Party Services

**Essential:**
- GitHub repository (for CI/CD)
- Domain registrar (for DNS)
- Dodo Payments account (billing integration - https://app.dodopayments.com)
- OAuth providers (Google, GitHub)
- Claude API access (Anthropic)

**Optional:**
- Sentry (error tracking)
- DataDog/CloudWatch (monitoring)
- PagerDuty (alerting)

### 4. Environment Variables

**Backend (.env):**
```bash
# Django
SECRET_KEY=<random-50-char-string>
DEBUG=False
ALLOWED_HOSTS=api.cocotestai.com,*.cocotestai.com
DJANGO_SETTINGS_MODULE=coco_testai.settings.production

# Database
DB_ENGINE=django.db.backends.postgresql
DB_NAME=coco_testai
DB_USER=coco_admin
DB_PASSWORD=<secure-password>
DB_HOST=<rds-endpoint-or-azure-postgres-fqdn>
DB_PORT=5432

# Redis
REDIS_URL=redis://<elasticache-or-azure-cache-endpoint>:6379/0

# Storage
USE_S3=True  # or USE_AZURE_BLOB=True
AWS_STORAGE_BUCKET_NAME=coco-artifacts-prod
AWS_S3_REGION_NAME=us-east-1
# OR
AZURE_STORAGE_ACCOUNT_NAME=cocoartifacts
AZURE_STORAGE_CONTAINER_NAME=artifacts

# OAuth
GOOGLE_CLIENT_ID=<google-oauth-client-id>
GOOGLE_CLIENT_SECRET=<google-oauth-secret>
GITHUB_CLIENT_ID=<github-oauth-client-id>
GITHUB_CLIENT_SECRET=<github-oauth-secret>

# Billing (Dodo Payments)
# Get from: https://app.dodopayments.com/developer/api-keys
DODO_PAYMENTS_API_KEY=<dodo-api-key>
DODO_WEBHOOK_SECRET=<dodo-webhook-secret-whsec_format>

# AI Integration
ANTHROPIC_API_KEY=<claude-api-key>
GRPC_AGENT_PORT=50051

# Security
CORS_ALLOWED_ORIGINS=https://app.cocotestai.com,https://www.cocotestai.com
CSRF_TRUSTED_ORIGINS=https://app.cocotestai.com

# Kubernetes
KUBECONFIG=/home/coco/.kube/config
TEST_EXECUTION_NAMESPACE=test-runners
```

**Webapp (.env.production):**
```bash
VITE_API_BASE_URL=https://api.cocotestai.com
VITE_ENVIRONMENT=production

# NOTE: Dodo Payments doesn't require frontend API keys
# Backend returns checkout URLs directly, no VITE_DODO_* variables needed
```

---

## Proposed Architecture

### High-Level Design

```
┌─────────────────────────────────────────────────────────────┐
│                      CI/CD Pipeline                          │
│                    (GitHub Actions)                          │
└────────────┬────────────────────────────────┬───────────────┘
             │                                │
             ▼                                ▼
    ┌────────────────┐              ┌────────────────┐
    │  Terraform     │              │   Ansible      │
    │  (Provision)   │─────────────▶│  (Configure)   │
    └────────────────┘              └────────────────┘
             │                                │
             ▼                                ▼
    ┌─────────────────────────────────────────────────┐
    │         Cloud Provider (AWS or Azure)           │
    ├─────────────────────────────────────────────────┤
    │                                                  │
    │  ┌──────────────┐          ┌──────────────┐   │
    │  │   Webapp     │          │   Backend    │   │
    │  │   (Static)   │          │   (VM)       │   │
    │  │              │          │              │   │
    │  │ S3/Blob ─────┼──────────┤ EC2/Azure VM │   │
    │  │ + CDN        │          │              │   │
    │  └──────────────┘          │ • Django     │   │
    │                             │ • PostgreSQL │   │
    │                             │ • Redis      │   │
    │                             │ • Kubernetes │   │
    │                             └──────────────┘   │
    │                                                  │
    └─────────────────────────────────────────────────┘
```

### Component Breakdown

#### 1. Infrastructure as Code (Terraform)

**Purpose:** Provision cloud resources in a cloud-agnostic way

**Modules:**
- `modules/compute/` - VM instances (EC2/Azure VM)
- `modules/database/` - PostgreSQL (RDS/Azure Database)
- `modules/cache/` - Redis (ElastiCache/Azure Cache)
- `modules/storage/` - Object storage (S3/Blob Storage)
- `modules/network/` - VPC, subnets, security groups
- `modules/cdn/` - CDN (CloudFront/Azure CDN)
- `modules/dns/` - DNS records (Route53/Azure DNS)
- `modules/ssl/` - SSL certificates (ACM/Key Vault)

**Provider Abstraction:**
```hcl
# environments/prod/main.tf
variable "cloud_provider" {
  description = "Cloud provider: aws or azure"
  type        = string
  default     = "aws"
}

module "compute" {
  source = "../../modules/compute"

  cloud_provider = var.cloud_provider
  instance_type  = var.cloud_provider == "aws" ? "t3.xlarge" : "Standard_D4s_v3"
  # ...
}
```

#### 2. Configuration Management (Ansible)

**Purpose:** Configure VMs, install dependencies, deploy applications

**Playbooks:**
- `playbooks/backend-setup.yml` - Install Python, PostgreSQL client, Redis client
- `playbooks/backend-deploy.yml` - Deploy Django app, create systemd services
- `playbooks/kubernetes-setup.yml` - Install minikube, configure test execution
- `playbooks/monitoring-setup.yml` - Install DataDog/Azure Monitor agent

**Inventory:**
```ini
[backend_servers]
backend-prod-1 ansible_host=<ec2-or-azure-vm-ip>

[backend_servers:vars]
ansible_user=ubuntu  # or azureuser
ansible_python_interpreter=/usr/bin/python3
cloud_provider=aws  # or azure
```

#### 3. CI/CD Pipeline (GitHub Actions)

**Workflows:**

**`.github/workflows/backend-deploy.yml`:**
```yaml
name: Deploy Backend

on:
  push:
    branches: [main, demo, test]
    paths:
      - 'coco-testai-with-copilot-engine/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set environment
        run: |
          if [ "${{ github.ref }}" == "refs/heads/main" ]; then
            echo "ENV=prod" >> $GITHUB_ENV
          elif [ "${{ github.ref }}" == "refs/heads/demo" ]; then
            echo "ENV=demo" >> $GITHUB_ENV
          else
            echo "ENV=test" >> $GITHUB_ENV
          fi

      - name: Configure AWS/Azure credentials
        # Conditional based on cloud_provider secret

      - name: Terraform Apply
        run: |
          cd terraform/environments/${{ env.ENV }}
          terraform init
          terraform apply -auto-approve

      - name: Run Ansible Deployment
        run: |
          cd ansible
          ansible-playbook -i inventories/${{ env.ENV }} playbooks/backend-deploy.yml

      - name: Run smoke tests
        run: |
          curl -f https://api-${{ env.ENV }}.cocotestai.com/api/health/
```

**`.github/workflows/webapp-deploy.yml`:**
```yaml
name: Deploy Webapp

on:
  push:
    branches: [main, demo, test]
    paths:
      - 'coco-testai-webapp/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Build webapp
        run: |
          cd coco-testai-webapp
          npm ci
          npm run build

      - name: Deploy to S3/Azure Blob
        run: |
          if [ "${{ secrets.CLOUD_PROVIDER }}" == "aws" ]; then
            aws s3 sync dist/ s3://${{ secrets.S3_BUCKET }}/ --delete
            aws cloudfront create-invalidation --distribution-id ${{ secrets.CF_DIST_ID }}
          else
            az storage blob upload-batch -d '$web' -s dist/ --account-name ${{ secrets.AZURE_STORAGE_ACCOUNT }}
            az cdn endpoint purge --resource-group ${{ secrets.AZURE_RG }} --name ${{ secrets.CDN_ENDPOINT }}
          fi
```

#### 4. Containerization Strategy

**Backend Docker Image (Optional Enhancement):**
```dockerfile
# Dockerfile
FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    redis-tools \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 8000 50051

ENTRYPOINT ["docker-entrypoint.sh"]
```

**Benefits:**
- Consistent environment across dev/prod
- Easier scaling (ECS/AKS instead of VMs)
- Simpler rollbacks (tag-based deployments)
- Better resource utilization

**Migration Path:**
- Phase 1: Deploy to VMs using Ansible (current plan)
- Phase 2: Containerize backend, deploy to ECS/AKS (future enhancement)

---

## Multi-Environment Management

The deployment system supports **unlimited environments** beyond the standard prod/demo/test. This enables flexible testing, staging, customer demos, and feature-specific instances.

### Environment Types

**Standard Environments (Always Present):**
- `prod` - Production environment (high availability, full resources)
- `demo` - Demo environment (medium resources, latest features)
- `test` - Testing environment (minimal resources, development builds)

**Dynamic Environments (On-Demand):**
- `staging` - Pre-production staging
- `uat` - User acceptance testing
- `test-instance-*` - Temporary test instances
- `feature-*` - Feature branch deployments
- `customer-demo-*` - Customer-specific demo instances
- Any custom name you need

### Creating New Environments

#### Method 1: Using Environment Template (Recommended)

**Step 1: Create environment directory**
```bash
# Copy template from existing environment
cp -r terraform/environments/demo terraform/environments/uat

# Or use helper script (we'll create this)
./scripts/create-environment.sh uat aws medium
```

**Step 2: Customize configuration**
```bash
# Edit terraform/environments/uat/terraform.tfvars
cd terraform/environments/uat
nano terraform.tfvars
```

**Example configuration for UAT environment:**
```hcl
# terraform/environments/uat/terraform.tfvars

cloud_provider = "aws"
project_name   = "coco-testai"
environment    = "uat"

# Instance sizing (medium - between test and prod)
instance_count = 2
instance_type  = "t3.large"

# Database
database_instance_class = "db.t3.medium"
database_storage_gb     = 50
database_name           = "coco_testai_uat"
database_master_user    = "coco_admin"

# Network
vpc_cidr           = "10.2.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]

# Storage
storage_bucket_name = "coco-artifacts-uat"

# CDN
cdn_domain_name = "uat.cocotestai.com"

# Tags
tags = {
  Project     = "Coco TestAI"
  Environment = "UAT"
  ManagedBy   = "Terraform"
  CostCenter  = "Engineering"
  Purpose     = "User Acceptance Testing"
}
```

**Step 3: Create Ansible inventory**
```bash
mkdir -p ansible/inventories/uat
touch ansible/inventories/uat/hosts.ini
```

**Step 4: Deploy via GitHub Actions**
```
1. Go to: Actions → "Deploy Infrastructure"
2. Click: "Run workflow"
3. Select/Enter: environment = "uat"
4. Select: cloud_provider = "aws"
5. Select: action = "apply"
6. Click: "Run workflow"
```

**Step 5: Application deploys automatically**
- Terraform creates infrastructure
- Ansible inventory auto-updates
- Application deploys on next code push to `main` branch
- Or trigger manual deployment workflow

**Time to create:** 10-15 minutes
**Result:** Fully functional UAT environment at `https://uat.cocotestai.com`

---

#### Method 2: Helper Script (Fastest)

We'll create a CLI tool for environment management:

```bash
# Create new environment
./scripts/deploy-cli.sh create uat \
  --cloud aws \
  --size medium \
  --domain uat.cocotestai.com

# What it does:
# 1. Creates terraform/environments/uat/ with template
# 2. Generates terraform.tfvars with appropriate sizing
# 3. Creates ansible inventory directory
# 4. Optionally triggers deployment
```

**Script will prompt:**
```
Creating new environment: uat
Cloud provider: aws
Instance size: medium (t3.large, db.t3.medium)
Estimated cost: $200/month

Create Ansible inventory? [Y/n]: Y
Deploy immediately? [y/N]: N

✓ Environment 'uat' created successfully
✓ Ansible inventory created

Next steps:
  1. Review configuration: terraform/environments/uat/terraform.tfvars
  2. Deploy: ./scripts/deploy-cli.sh deploy uat
  Or use GitHub Actions workflow
```

---

#### Method 3: Branch-Based Auto-Deployment (Feature Environments)

For feature branches, automatically create temporary environments:

**Configuration (.github/workflows/deploy-feature-env.yml):**
```yaml
name: Deploy Feature Environment

on:
  push:
    branches:
      - 'feature/**'

jobs:
  deploy-feature:
    runs-on: ubuntu-latest
    steps:
      - name: Extract environment name
        id: env
        run: |
          # feature/new-ui → feature-new-ui
          BRANCH=$(echo ${{ github.ref }} | sed 's/refs\/heads\/feature\///')
          ENV_NAME="feature-${BRANCH}"
          echo "env_name=${ENV_NAME}" >> $GITHUB_OUTPUT

      - name: Check if environment exists
        id: check
        run: |
          if [ -d "terraform/environments/${{ steps.env.outputs.env_name }}" ]; then
            echo "exists=true" >> $GITHUB_OUTPUT
          else
            echo "exists=false" >> $GITHUB_OUTPUT
          fi

      - name: Create environment (if new)
        if: steps.check.outputs.exists == 'false'
        run: |
          ./scripts/create-environment.sh ${{ steps.env.outputs.env_name }} \
            --cloud aws \
            --size small \
            --auto-confirm

      - name: Deploy application
        run: |
          cd terraform/environments/${{ steps.env.outputs.env_name }}
          terraform apply -auto-approve
```

**Usage:**
```
Create branch: feature/new-ui
Push code → Auto-creates environment: feature-new-ui
URL: https://feature-new-ui.cocotestai.com
Delete branch → Auto-destroys environment (optional)
```

---

### Environment Sizing Presets

**2026 Best Practice:** Size presets are defined in external YAML configuration files for maintainability, validation, and GitOps workflows.

**File: `scripts/config/size-presets.yaml`**

```yaml
# Size preset configurations for deployment CLI
# Based on 2026 DevOps best practices
# See: https://kubernetes.io/docs/concepts/configuration/overview/

version: "1.0"
last_updated: "2026-03-01"

presets:
  small:
    description: "Development and testing environments"
    use_case: "Low traffic, cost optimization"
    estimated_cost:
      monthly_usd: "80-100"
      yearly_usd: "960-1200"

    aws:
      compute:
        instance_type: "t3.medium"
        instance_count: 1
        root_volume_size: 30
        root_volume_type: "gp3"

      database:
        engine: "postgres"
        engine_version: "15.4"
        instance_class: "db.t3.micro"
        allocated_storage: 20
        backup_retention_days: 7

      cache:
        engine: "redis"
        engine_version: "7.0"
        node_type: "cache.t3.micro"
        num_cache_nodes: 1

    azure:
      compute:
        vm_size: "Standard_B2s"
        instance_count: 1
        os_disk_size_gb: 30
        os_disk_type: "Premium_LRS"

      database:
        sku_name: "B_Standard_B1ms"
        storage_mb: 20480
        backup_retention_days: 7

      cache:
        sku_name: "Basic"
        capacity: 0  # 250 MB

  medium:
    description: "Staging and UAT environments"
    use_case: "Moderate traffic, pre-production testing"
    estimated_cost:
      monthly_usd: "200-250"
      yearly_usd: "2400-3000"

    aws:
      compute:
        instance_type: "t3.xlarge"
        instance_count: 2
        root_volume_size: 50
        root_volume_type: "gp3"

      database:
        engine: "postgres"
        engine_version: "15.4"
        instance_class: "db.t3.medium"
        allocated_storage: 50
        backup_retention_days: 14

      cache:
        engine: "redis"
        engine_version: "7.0"
        node_type: "cache.t3.small"
        num_cache_nodes: 1

    azure:
      compute:
        vm_size: "Standard_D4s_v3"
        instance_count: 2
        os_disk_size_gb: 50
        os_disk_type: "Premium_LRS"

      database:
        sku_name: "GP_Standard_D4s_v3"
        storage_mb: 51200
        backup_retention_days: 14

      cache:
        sku_name: "Standard"
        capacity: 1  # 1 GB

  large:
    description: "Production environments"
    use_case: "High traffic, mission-critical workloads"
    estimated_cost:
      monthly_usd: "500-600"
      yearly_usd: "6000-7200"

    aws:
      compute:
        instance_type: "m5.2xlarge"
        instance_count: 3
        root_volume_size: 100
        root_volume_type: "gp3"
        enable_autoscaling: true
        min_instances: 2
        max_instances: 6

      database:
        engine: "postgres"
        engine_version: "15.4"
        instance_class: "db.m5.large"
        allocated_storage: 100
        backup_retention_days: 30
        multi_az: true

      cache:
        engine: "redis"
        engine_version: "7.0"
        node_type: "cache.m5.large"
        num_cache_nodes: 2
        automatic_failover: true

    azure:
      compute:
        vm_size: "Standard_D8s_v3"
        instance_count: 3
        os_disk_size_gb: 100
        os_disk_type: "Premium_LRS"
        enable_autoscaling: true
        min_instances: 2
        max_instances: 6

      database:
        sku_name: "GP_Standard_D8s_v3"
        storage_mb: 102400
        backup_retention_days: 30
        high_availability: true

      cache:
        sku_name: "Premium"
        capacity: 1  # 6 GB
        replica_count: 1
```

**Why YAML Configuration (2026 Best Practice):**
1. ✅ **Version controlled** - Track infrastructure decisions in Git
2. ✅ **Validated** - JSON Schema validation catches errors
3. ✅ **IDE support** - Autocomplete, syntax highlighting
4. ✅ **Non-developers friendly** - Easy to read and modify
5. ✅ **GitOps ready** - Clean diffs, easy PR reviews
6. ✅ **Scalable** - Add new presets without code changes
7. ✅ **Industry standard** - Used by Kubernetes, Helm, AWS CloudFormation

**JSON Schema Validation (`scripts/config/schemas/size-preset-schema.json`):**
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Size Preset Configuration",
  "type": "object",
  "required": ["version", "presets"],
  "properties": {
    "version": {
      "type": "string",
      "pattern": "^[0-9]+\\.[0-9]+$"
    },
    "presets": {
      "type": "object",
      "patternProperties": {
        "^[a-z-]+$": {
          "type": "object",
          "required": ["description", "estimated_cost", "aws", "azure"],
          "properties": {
            "description": { "type": "string" },
            "use_case": { "type": "string" },
            "estimated_cost": {
              "type": "object",
              "required": ["monthly_usd"],
              "properties": {
                "monthly_usd": { "type": "string" },
                "yearly_usd": { "type": "string" }
              }
            },
            "aws": {
              "type": "object",
              "required": ["compute", "database", "cache"]
            },
            "azure": {
              "type": "object",
              "required": ["compute", "database", "cache"]
            }
          }
        }
      }
    }
  }
}
```

**CLI Usage:**
```bash
# View available presets
./scripts/deploy-cli.sh list-presets

# Output:
# Available Size Presets:
#
# small - Development and testing environments
#   AWS: t3.medium (2 vCPU, 4 GB) x1
#   Cost: $80-100/month
#
# medium - Staging and UAT environments
#   AWS: t3.xlarge (4 vCPU, 16 GB) x2
#   Cost: $200-250/month
#
# large - Production environments
#   AWS: m5.2xlarge (8 vCPU, 32 GB) x3
#   Cost: $500-600/month

# Create environment with preset
./scripts/deploy-cli.sh create demo --preset small --cloud aws
```

---

### Environment Lifecycle

#### Listing Environments

```bash
# List all environments
./scripts/deploy-cli.sh list

# Output:
# Environments:
#   prod          AWS    t3.xlarge x2    Running    $550/month
#   demo          AWS    t3.large x2     Running    $220/month
#   test          AWS    t3.medium x1    Running    $90/month
#   uat           AWS    t3.large x2     Running    $200/month
#   feature-new-ui AWS   t3.medium x1    Running    $80/month

# Or via Terraform workspaces:
cd terraform/environments
ls -d */ | sed 's/\///'
```

#### Updating Environment

```bash
# Scale up instance count
cd terraform/environments/uat
nano terraform.tfvars  # Change instance_count = 2 to 3
terraform apply

# Or use helper script
./scripts/deploy-cli.sh scale uat --instances 3
```

#### Destroying Environment

**Via CLI:**
```bash
./scripts/deploy-cli.sh destroy uat

# Prompts:
# WARNING: This will destroy environment 'uat' and all data!
# Resources to be destroyed:
#   - 2 EC2 instances
#   - RDS PostgreSQL database
#   - Redis cache
#   - S3 bucket (data will be LOST)
#   - Load balancer
#
# Type 'uat' to confirm: uat
#
# Destroying environment...
# ✓ Environment destroyed (saved $200/month)
```

**Via GitHub Actions:**
```
Actions → "Deploy Infrastructure"
Environment: uat
Action: destroy
Confirm: ✓
```

**Via Terraform:**
```bash
cd terraform/environments/uat
terraform destroy
```

---

### Updated GitHub Actions Workflow

The workflow will support **dynamic environment selection**:

**Option A: Dropdown with All Environments (Auto-Detected)**

```yaml
# .github/workflows/deploy-infrastructure.yml

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        type: string
        # Dynamically populated from terraform/environments/* folders

      cloud_provider:
        description: 'Cloud provider'
        required: true
        type: choice
        options:
          - aws
          - azure

      action:
        description: 'Action'
        required: true
        type: choice
        options:
          - apply
          - destroy
          - plan

jobs:
  validate-environment:
    runs-on: ubuntu-latest
    steps:
      - name: Check environment exists
        run: |
          if [ ! -d "terraform/environments/${{ github.event.inputs.environment }}" ]; then
            echo "❌ Environment '${{ github.event.inputs.environment }}' does not exist"
            echo "Available environments:"
            ls terraform/environments/
            exit 1
          fi

  deploy:
    needs: validate-environment
    runs-on: ubuntu-latest
    steps:
      # ... rest of deployment steps
```

**Option B: Create New Environment On-The-Fly**

```yaml
on:
  workflow_dispatch:
    inputs:
      action_type:
        description: 'Action type'
        required: true
        type: choice
        options:
          - deploy-existing
          - create-new
          - destroy

      environment:
        description: 'Environment name'
        required: true
        type: string

      environment_size:
        description: 'Size (for new environments)'
        type: choice
        options:
          - small
          - medium
          - large

jobs:
  create-environment:
    if: github.event.inputs.action_type == 'create-new'
    steps:
      - name: Create environment from template
        run: |
          ./scripts/create-environment.sh \
            ${{ github.event.inputs.environment }} \
            --cloud ${{ github.event.inputs.cloud_provider }} \
            --size ${{ github.event.inputs.environment_size }} \
            --auto-confirm
```

---

### Environment-Specific Configuration

Each environment can have unique settings:

**DNS:**
- `prod` → `app.cocotestai.com` + `api.cocotestai.com`
- `demo` → `demo.cocotestai.com` + `api-demo.cocotestai.com`
- `uat` → `uat.cocotestai.com` + `api-uat.cocotestai.com`
- `feature-*` → `feature-*.cocotestai.com` + `api-feature-*.cocotestai.com`

**Database:**
- Separate database per environment
- Prod has backups enabled, others optional
- Test environments can use smaller instances

**Redis:**
- Separate cache per environment
- Prod uses ElastiCache/Azure Cache
- Test environments can use single-node

**Kubernetes:**
- Shared Minikube for test environments (cost savings)
- Dedicated cluster for prod

---

### Cost Tracking Per Environment

**Terraform Tagging:**
Every resource tagged with environment name:
```hcl
tags = {
  Environment = var.environment
  Project     = "Coco TestAI"
  ManagedBy   = "Terraform"
}
```

**AWS Cost Explorer:**
```
Filter by tag: Environment = "uat"
Shows exact monthly cost for UAT environment
```

**Cost Monitoring Script:**
```bash
./scripts/environment-costs.sh

# Output:
# Environment Costs (Last 30 Days):
#   prod            $547.32
#   demo            $218.45
#   test            $89.21
#   uat             $201.67
#   feature-new-ui  $82.11
#   TOTAL           $1,138.76
```

---

### Environment Promotion Strategy

**Code promotion path:**
```
feature branch → test → demo → uat → prod
```

**Infrastructure promotion:**
```bash
# Tested in demo, promote config to prod
cd terraform/environments/demo
cp terraform.tfvars ../prod/terraform.tfvars
cd ../prod
# Edit for prod sizing
nano terraform.tfvars
terraform apply
```

**Database promotion:**
```bash
# Copy demo database to uat for testing
./scripts/clone-database.sh \
  --from demo \
  --to uat \
  --sanitize-pii  # Remove sensitive data
```

---

### Environment Isolation

**Network Isolation:**
- Each environment has separate VPC (AWS) or VNet (Azure)
- No cross-environment network access
- Separate security groups per environment

**Data Isolation:**
- Separate databases (no shared schema)
- Separate Redis instances
- Separate S3 buckets/Blob containers

**Credential Isolation:**
- Environment-specific secrets in AWS Secrets Manager/Azure Key Vault
- Namespace: `coco-testai/{environment}/{secret-name}`
- Example: `coco-testai/uat/django-secret-key`

---

### Helper Scripts

We'll create a comprehensive CLI tool: `scripts/deploy-cli.sh`

**Usage:**
```bash
# Create environment
./deploy-cli.sh create <env-name> [--cloud aws|azure] [--size small|medium|large]

# List environments
./deploy-cli.sh list

# Deploy environment
./deploy-cli.sh deploy <env-name>

# Scale environment
./deploy-cli.sh scale <env-name> --instances 3

# Destroy environment
./deploy-cli.sh destroy <env-name>

# Clone environment
./deploy-cli.sh clone <source-env> <target-env>

# Get environment info
./deploy-cli.sh info <env-name>

# Show costs
./deploy-cli.sh costs [env-name]

# SSH into environment
./deploy-cli.sh ssh <env-name> [--instance 1]

# View logs
./deploy-cli.sh logs <env-name> [--service daphne]
```

**Example Session:**
```bash
$ ./deploy-cli.sh create uat --cloud aws --size medium
Creating environment: uat
Cloud: AWS
Size: medium (t3.large x2, db.t3.medium)
Estimated cost: $200/month

✓ Created terraform/environments/uat/
✓ Generated terraform.tfvars
✓ Created ansible inventory
✓ Ready to deploy

Deploy now? [y/N]: y

Deploying infrastructure...
[Terraform output...]
✓ Infrastructure deployed in 12m 34s

Deploying application...
[Ansible output...]
✓ Application deployed in 3m 21s

Environment 'uat' is ready!
URL: https://uat.cocotestai.com
API: https://api-uat.cocotestai.com

$ ./deploy-cli.sh list
Environments:
  prod   AWS   t3.xlarge x2   Running   $550/month
  demo   AWS   t3.large x2    Running   $220/month
  test   AWS   t3.medium x1   Running   $90/month
  uat    AWS   t3.large x2    Running   $200/month

Total: 4 environments, $1,060/month

$ ./deploy-cli.sh destroy test
WARNING: This will destroy 'test' environment and all data!
Type 'test' to confirm: test
Destroying...
✓ Destroyed (saved $90/month)
```

**CLI Implementation (YAML-based):**

`scripts/deploy-cli.sh` (excerpt):
```bash
#!/bin/bash
set -euo pipefail

# ============================================
# Configuration
# ============================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"
PRESETS_FILE="$CONFIG_DIR/size-presets.yaml"
SCHEMA_FILE="$CONFIG_DIR/schemas/size-preset-schema.json"

# ============================================
# Dependency Check
# ============================================
check_dependencies() {
    local missing=()

    # Check yq (YAML processor)
    if ! command -v yq &> /dev/null; then
        missing+=("yq")
    fi

    # Check jq (JSON processor)
    if ! command -v jq &> /dev/null; then
        missing+=("jq")
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        echo "❌ Missing required dependencies: ${missing[*]}"
        echo ""
        echo "Install with:"
        echo "  brew install yq jq  # macOS"
        echo "  apt-get install yq jq  # Ubuntu/Debian"
        echo "  choco install yq jq  # Windows"
        exit 1
    fi
}

# ============================================
# Validate Configuration
# ============================================
validate_config() {
    echo "🔍 Validating configuration..."

    # Convert YAML to JSON and validate against schema
    if yq eval -o=json "$PRESETS_FILE" | \
       jq -e . > /dev/null 2>&1; then
        echo "✓ Configuration is valid YAML"
    else
        echo "❌ Invalid YAML in $PRESETS_FILE"
        exit 1
    fi

    # Optional: JSON Schema validation if ajv-cli is installed
    if command -v ajv &> /dev/null; then
        if yq eval -o=json "$PRESETS_FILE" | \
           ajv validate -s "$SCHEMA_FILE" -d - 2>&1; then
            echo "✓ Configuration passes schema validation"
        else
            echo "⚠️  Configuration has schema validation warnings"
        fi
    fi
}

# ============================================
# Load Preset Configuration
# ============================================
load_preset() {
    local preset=$1
    local cloud=$2

    # Check if preset exists
    if ! yq eval ".presets | has(\"$preset\")" "$PRESETS_FILE" | grep -q "true"; then
        echo "❌ Unknown preset: $preset"
        echo ""
        echo "Available presets:"
        yq eval '.presets | keys | .[]' "$PRESETS_FILE"
        exit 1
    fi

    # Check if cloud provider is supported
    if ! yq eval ".presets.$preset | has(\"$cloud\")" "$PRESETS_FILE" | grep -q "true"; then
        echo "❌ Preset '$preset' not available for cloud '$cloud'"
        exit 1
    fi

    # Extract configuration values
    INSTANCE_TYPE=$(yq eval ".presets.$preset.$cloud.compute.instance_type" "$PRESETS_FILE")
    INSTANCE_COUNT=$(yq eval ".presets.$preset.$cloud.compute.instance_count" "$PRESETS_FILE")
    ROOT_VOLUME_SIZE=$(yq eval ".presets.$preset.$cloud.compute.root_volume_size" "$PRESETS_FILE")

    DB_INSTANCE_CLASS=$(yq eval ".presets.$preset.$cloud.database.instance_class" "$PRESETS_FILE")
    DB_STORAGE=$(yq eval ".presets.$preset.$cloud.database.allocated_storage" "$PRESETS_FILE")
    DB_BACKUP_RETENTION=$(yq eval ".presets.$preset.$cloud.database.backup_retention_days" "$PRESETS_FILE")

    REDIS_NODE_TYPE=$(yq eval ".presets.$preset.$cloud.cache.node_type" "$PRESETS_FILE")
    REDIS_NODES=$(yq eval ".presets.$preset.$cloud.cache.num_cache_nodes" "$PRESETS_FILE")

    # Get description and cost for display
    PRESET_DESC=$(yq eval ".presets.$preset.description" "$PRESETS_FILE")
    PRESET_COST=$(yq eval ".presets.$preset.estimated_cost.monthly_usd" "$PRESETS_FILE")

    # Validate extracted values
    if [ "$INSTANCE_TYPE" == "null" ] || [ -z "$INSTANCE_TYPE" ]; then
        echo "❌ Failed to extract instance type from preset"
        exit 1
    fi
}

# ============================================
# List Available Presets
# ============================================
list_presets() {
    echo "Available Size Presets:"
    echo ""

    # Get all preset names
    presets=$(yq eval '.presets | keys | .[]' "$PRESETS_FILE")

    for preset in $presets; do
        desc=$(yq eval ".presets.$preset.description" "$PRESETS_FILE")
        cost=$(yq eval ".presets.$preset.estimated_cost.monthly_usd" "$PRESETS_FILE")

        # AWS details
        aws_instance=$(yq eval ".presets.$preset.aws.compute.instance_type" "$PRESETS_FILE")
        aws_count=$(yq eval ".presets.$preset.aws.compute.instance_count" "$PRESETS_FILE")

        # Azure details
        azure_vm=$(yq eval ".presets.$preset.azure.compute.vm_size" "$PRESETS_FILE")
        azure_count=$(yq eval ".presets.$preset.azure.compute.instance_count" "$PRESETS_FILE")

        echo "📦 $preset - $desc"
        echo "   AWS: $aws_instance x$aws_count"
        echo "   Azure: $azure_vm x$azure_count"
        echo "   Cost: \$$cost/month"
        echo ""
    done
}

# ============================================
# Create Environment
# ============================================
create_environment() {
    local env_name=$1
    local cloud=${2:-aws}
    local preset=${3:-medium}

    echo "Creating environment: $env_name"
    echo "Cloud: $cloud"
    echo "Preset: $preset"
    echo ""

    # Load preset configuration
    load_preset "$preset" "$cloud"

    echo "Configuration loaded:"
    echo "  Description: $PRESET_DESC"
    echo "  Compute: $INSTANCE_TYPE x$INSTANCE_COUNT"
    echo "  Database: $DB_INSTANCE_CLASS ($DB_STORAGE GB)"
    echo "  Redis: $REDIS_NODE_TYPE x$REDIS_NODES"
    echo "  Estimated cost: \$$PRESET_COST/month"
    echo ""

    # Create Terraform directory
    mkdir -p "terraform/environments/$env_name"

    # Generate terraform.tfvars from preset
    cat > "terraform/environments/$env_name/terraform.tfvars" <<EOF
# Generated from preset: $preset
# Cloud provider: $cloud
# Generated on: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

cloud_provider = "$cloud"
project_name   = "coco-testai"
environment    = "$env_name"

# Compute
instance_type  = "$INSTANCE_TYPE"
instance_count = $INSTANCE_COUNT
root_volume_size = $ROOT_VOLUME_SIZE

# Database
database_instance_class = "$DB_INSTANCE_CLASS"
database_storage_gb     = $DB_STORAGE
database_backup_retention = $DB_BACKUP_RETENTION

# Redis
redis_node_type     = "$REDIS_NODE_TYPE"
redis_num_nodes     = $REDIS_NODES

# Tags
tags = {
  Project     = "Coco TestAI"
  Environment = "$env_name"
  Preset      = "$preset"
  ManagedBy   = "Terraform"
  CreatedBy   = "deploy-cli"
  CreatedAt   = "$(date -u +"%Y-%m-%d")"
}
EOF

    echo "✓ Created terraform/environments/$env_name/terraform.tfvars"

    # Create Ansible inventory directory
    mkdir -p "ansible/inventories/$env_name"
    touch "ansible/inventories/$env_name/hosts.ini"

    echo "✓ Created ansible/inventories/$env_name/"
    echo ""
    echo "Environment '$env_name' configured successfully!"
}

# ============================================
# Main Command Dispatcher
# ============================================
main() {
    check_dependencies

    case "${1:-}" in
        list-presets|presets|sizes)
            list_presets
            ;;

        create)
            if [ $# -lt 2 ]; then
                echo "Usage: $0 create <env-name> [--cloud aws|azure] [--preset small|medium|large]"
                exit 1
            fi

            ENV_NAME=$2
            CLOUD="aws"
            PRESET="medium"

            # Parse flags
            shift 2
            while [[ $# -gt 0 ]]; do
                case $1 in
                    --cloud)
                        CLOUD="$2"
                        shift 2
                        ;;
                    --preset|--size)
                        PRESET="$2"
                        shift 2
                        ;;
                    *)
                        echo "Unknown option: $1"
                        exit 1
                        ;;
                esac
            done

            validate_config
            create_environment "$ENV_NAME" "$CLOUD" "$PRESET"
            ;;

        *)
            echo "Coco TestAI Deployment CLI"
            echo ""
            echo "Usage:"
            echo "  $0 list-presets                 List available size presets"
            echo "  $0 create <env> [options]       Create new environment"
            echo "  $0 deploy <env>                 Deploy environment"
            echo "  $0 destroy <env>                Destroy environment"
            echo ""
            echo "Options:"
            echo "  --cloud <aws|azure>             Cloud provider (default: aws)"
            echo "  --preset <small|medium|large>   Size preset (default: medium)"
            ;;
    esac
}

main "$@"
```

**Directory Structure:**
```
scripts/
├── deploy-cli.sh                    # Main CLI tool
├── config/
│   ├── size-presets.yaml            # Size configurations (YAML)
│   ├── network-presets.yaml         # Network CIDR presets
│   ├── security-policies.yaml       # Security group templates
│   └── schemas/
│       ├── size-preset-schema.json  # JSON Schema validation
│       └── network-preset-schema.json
├── lib/
│   ├── aws-helpers.sh               # AWS-specific functions
│   ├── azure-helpers.sh             # Azure-specific functions
│   └── terraform-helpers.sh         # Terraform wrapper
└── README.md
```

**Benefits of This Approach:**
1. ✅ **Separation of concerns** - Logic in `.sh`, data in `.yaml`
2. ✅ **Easy customization** - Non-developers can edit YAML
3. ✅ **Version controlled** - Track preset changes in Git
4. ✅ **Validated** - JSON Schema catches configuration errors
5. ✅ **IDE support** - VSCode YAML extension provides autocomplete
6. ✅ **Testable** - Can unit test YAML parsing independently
7. ✅ **GitOps ready** - Clean diffs, reviewable changes
8. ✅ **Industry standard** - Aligns with Kubernetes, Helm, AWS practices

---

### Environment Variables Management

**Structure:**
```
.env.example                    # Template
.env.prod                       # Production (gitignored)
.env.demo                       # Demo (gitignored)
.env.test                       # Test (gitignored)
.env.<any-env>                  # Dynamic environments
```

**Ansible template approach:**
```yaml
# ansible/templates/backend.env.j2

DEBUG={{ 'False' if environment == 'prod' else 'True' }}
ALLOWED_HOSTS={{ environment }}.cocotestai.com,api-{{ environment }}.cocotestai.com
DATABASE_URL={{ database_url }}
REDIS_URL={{ redis_url }}
# ... rest of variables
```

**Secrets in AWS Secrets Manager/Azure Key Vault:**
```bash
# Store secret for UAT environment
aws secretsmanager create-secret \
  --name coco-testai/uat/django-secret-key \
  --secret-string "random-secret-key-here"

# Application retrieves at runtime
SECRET_KEY = get_secret('coco-testai/uat/django-secret-key')
```

---

### Best Practices

1. **Naming Convention:**
   - Use lowercase, hyphens only
   - Format: `{purpose}-{detail}` (e.g., `uat`, `test-instance-2`, `feature-new-ui`)

2. **Resource Tagging:**
   - Always tag with: Environment, Project, ManagedBy, Owner, CostCenter
   - Enables cost tracking and lifecycle management

3. **Cleanup Policy:**
   - Feature environments auto-destroy after 7 days of inactivity
   - Test instances require manual destruction (prevent accidents)
   - Demo environments are permanent

4. **Cost Control:**
   - Set billing alerts per environment
   - Auto-stop non-prod instances outside business hours (optional)
   - Use spot instances for test environments

5. **Security:**
   - Never copy prod secrets to test environments
   - Use separate OAuth apps per environment
   - Sanitize data when copying databases

---

## Detailed Implementation Plan

### Phase 1: Terraform Infrastructure Setup (Week 1-2)

**Step 1.1: Create Terraform Directory Structure**
```
terraform/
├── modules/
│   ├── compute/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── providers/
│   │       ├── aws.tf
│   │       └── azure.tf
│   ├── database/
│   ├── cache/
│   ├── storage/
│   ├── network/
│   ├── cdn/
│   ├── dns/
│   └── ssl/
├── environments/
│   ├── prod/
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── demo/
│   └── test/
└── README.md
```

**Step 1.2: Implement Compute Module**

`terraform/modules/compute/main.tf`:
```hcl
locals {
  is_aws   = var.cloud_provider == "aws"
  is_azure = var.cloud_provider == "azure"
}

# AWS EC2 Instance
resource "aws_instance" "backend" {
  count         = local.is_aws ? var.instance_count : 0
  ami           = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = var.security_group_ids
  subnet_id              = var.subnet_id
  key_name               = var.ssh_key_name

  user_data = file("${path.module}/user-data/aws-init.sh")

  tags = merge(var.tags, {
    Name = "${var.project_name}-backend-${count.index + 1}"
  })
}

# Azure VM
resource "azurerm_linux_virtual_machine" "backend" {
  count               = local.is_azure ? var.instance_count : 0
  name                = "${var.project_name}-backend-${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.instance_type

  admin_username = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.backend[count.index].id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(file("${path.module}/user-data/azure-init.sh"))

  tags = var.tags
}

# Outputs
output "instance_ips" {
  value = local.is_aws ? aws_instance.backend[*].public_ip : azurerm_linux_virtual_machine.backend[*].public_ip_address
}
```

**Step 1.3: Implement Database Module**

`terraform/modules/database/main.tf`:
```hcl
# AWS RDS PostgreSQL
resource "aws_db_instance" "postgres" {
  count = local.is_aws ? 1 : 0

  identifier        = "${var.project_name}-postgres"
  engine            = "postgres"
  engine_version    = "15.4"
  instance_class    = var.instance_class
  allocated_storage = var.storage_gb

  db_name  = var.database_name
  username = var.master_username
  password = var.master_password

  vpc_security_group_ids = var.security_group_ids
  db_subnet_group_name   = var.subnet_group_name

  backup_retention_period = 7
  skip_final_snapshot     = false
  final_snapshot_identifier = "${var.project_name}-postgres-final-snapshot"

  tags = var.tags
}

# Azure Database for PostgreSQL
resource "azurerm_postgresql_flexible_server" "postgres" {
  count = local.is_azure ? 1 : 0

  name                = "${var.project_name}-postgres"
  resource_group_name = var.resource_group_name
  location            = var.location

  administrator_login    = var.master_username
  administrator_password = var.master_password

  sku_name   = var.instance_class
  storage_mb = var.storage_gb * 1024
  version    = "15"

  backup_retention_days = 7

  tags = var.tags
}

output "endpoint" {
  value = local.is_aws ? aws_db_instance.postgres[0].endpoint : azurerm_postgresql_flexible_server.postgres[0].fqdn
}
```

**Step 1.4: Create Environment Configuration**

`terraform/environments/prod/terraform.tfvars`:
```hcl
# Cloud provider selection
cloud_provider = "aws"  # Change to "azure" for Azure deployment

# Project settings
project_name = "coco-testai"
environment  = "prod"

# Compute
instance_count = 2
instance_type  = "t3.xlarge"  # AWS: t3.xlarge, Azure: Standard_D4s_v3

# Database
database_instance_class = "db.t3.large"  # AWS: db.t3.large, Azure: GP_Standard_D4s_v3
database_storage_gb     = 100
database_name           = "coco_testai"
database_master_user    = "coco_admin"

# Network
vpc_cidr = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]

# Storage
storage_bucket_name = "coco-artifacts-prod"

# CDN
cdn_domain_name = "app.cocotestai.com"

# Tags
tags = {
  Project     = "Coco TestAI"
  Environment = "Production"
  ManagedBy   = "Terraform"
  CostCenter  = "Engineering"
}
```

### Phase 2: Ansible Configuration (Week 2-3)

**Step 2.1: Create Ansible Directory Structure**
```
ansible/
├── inventories/
│   ├── prod/
│   │   └── hosts.ini
│   ├── demo/
│   └── test/
├── playbooks/
│   ├── backend-setup.yml
│   ├── backend-deploy.yml
│   ├── kubernetes-setup.yml
│   └── rollback.yml
├── roles/
│   ├── common/
│   ├── python/
│   ├── django/
│   ├── nginx/
│   ├── postgresql-client/
│   ├── redis-client/
│   └── kubernetes/
├── group_vars/
│   ├── all.yml
│   ├── prod.yml
│   └── demo.yml
└── ansible.cfg
```

**Step 2.2: Backend Setup Playbook**

`ansible/playbooks/backend-setup.yml`:
```yaml
---
- name: Setup Backend Server
  hosts: backend_servers
  become: yes

  vars:
    python_version: "3.10"
    project_user: "coco"
    project_dir: "/opt/coco-testai"

  roles:
    - common
    - python
    - postgresql-client
    - redis-client
    - nginx
    - kubernetes

  tasks:
    - name: Create project user
      user:
        name: "{{ project_user }}"
        home: "{{ project_dir }}"
        shell: /bin/bash
        create_home: yes

    - name: Install system dependencies
      apt:
        name:
          - git
          - build-essential
          - libpq-dev
          - python3-dev
          - python3-pip
          - virtualenv
          - supervisor
        state: present
        update_cache: yes

    - name: Create application directories
      file:
        path: "{{ item }}"
        state: directory
        owner: "{{ project_user }}"
        group: "{{ project_user }}"
      loop:
        - "{{ project_dir }}/app"
        - "{{ project_dir }}/logs"
        - "{{ project_dir }}/static"
        - "{{ project_dir }}/media"
```

**Step 2.3: Backend Deployment Playbook**

`ansible/playbooks/backend-deploy.yml`:
```yaml
---
- name: Deploy Backend Application
  hosts: backend_servers
  become: yes

  vars:
    project_user: "coco"
    project_dir: "/opt/coco-testai"
    git_repo: "https://github.com/your-org/coco-testai.git"
    git_branch: "{{ deploy_branch | default('main') }}"

  tasks:
    - name: Pull latest code from Git
      git:
        repo: "{{ git_repo }}"
        dest: "{{ project_dir }}/app"
        version: "{{ git_branch }}"
        force: yes
      become_user: "{{ project_user }}"

    - name: Create virtual environment
      command: "python3 -m venv {{ project_dir }}/venv"
      args:
        creates: "{{ project_dir }}/venv/bin/activate"
      become_user: "{{ project_user }}"

    - name: Install Python dependencies
      pip:
        requirements: "{{ project_dir }}/app/coco-testai-with-copilot-engine/requirements.txt"
        virtualenv: "{{ project_dir }}/venv"
      become_user: "{{ project_user }}"

    - name: Copy environment variables
      template:
        src: ../templates/backend.env.j2
        dest: "{{ project_dir }}/app/coco-testai-with-copilot-engine/.env"
        owner: "{{ project_user }}"
        group: "{{ project_user }}"
        mode: '0600'

    - name: Run database migrations
      django_manage:
        command: migrate
        app_path: "{{ project_dir }}/app/coco-testai-with-copilot-engine"
        virtualenv: "{{ project_dir }}/venv"
      become_user: "{{ project_user }}"

    - name: Collect static files
      django_manage:
        command: collectstatic
        app_path: "{{ project_dir }}/app/coco-testai-with-copilot-engine"
        virtualenv: "{{ project_dir }}/venv"
      become_user: "{{ project_user }}"

    - name: Create systemd service files
      template:
        src: "../templates/systemd/{{ item }}.service.j2"
        dest: "/etc/systemd/system/{{ item }}.service"
      loop:
        - coco-daphne
        - coco-grpc-agent
        - coco-celery-worker
        - coco-celery-beat
        - coco-pg-listener
      notify: Reload systemd

    - name: Enable and restart services
      systemd:
        name: "{{ item }}"
        enabled: yes
        state: restarted
        daemon_reload: yes
      loop:
        - coco-daphne
        - coco-grpc-agent
        - coco-celery-worker
        - coco-celery-beat
        - coco-pg-listener

    - name: Configure Nginx
      template:
        src: ../templates/nginx/coco-backend.conf.j2
        dest: /etc/nginx/sites-available/coco-backend
      notify: Reload Nginx

    - name: Enable Nginx site
      file:
        src: /etc/nginx/sites-available/coco-backend
        dest: /etc/nginx/sites-enabled/coco-backend
        state: link
      notify: Reload Nginx

  handlers:
    - name: Reload systemd
      systemd:
        daemon_reload: yes

    - name: Reload Nginx
      service:
        name: nginx
        state: reloaded
```

**Step 2.4: Systemd Service Templates**

`ansible/templates/systemd/coco-daphne.service.j2`:
```ini
[Unit]
Description=Coco TestAI Daphne ASGI Server
After=network.target postgresql.service redis.service

[Service]
Type=simple
User={{ project_user }}
Group={{ project_user }}
WorkingDirectory={{ project_dir }}/app/coco-testai-with-copilot-engine
Environment="PATH={{ project_dir }}/venv/bin"
EnvironmentFile={{ project_dir }}/app/coco-testai-with-copilot-engine/.env

ExecStart={{ project_dir }}/venv/bin/daphne \
    -b 0.0.0.0 \
    -p 8000 \
    coco_testai.asgi:application

Restart=always
RestartSec=10s

StandardOutput=append:{{ project_dir }}/logs/daphne.log
StandardError=append:{{ project_dir }}/logs/daphne.error.log

[Install]
WantedBy=multi-user.target
```

`ansible/templates/systemd/coco-celery-worker.service.j2`:
```ini
[Unit]
Description=Coco TestAI Celery Worker
After=network.target redis.service

[Service]
Type=simple
User={{ project_user }}
Group={{ project_user }}
WorkingDirectory={{ project_dir }}/app/coco-testai-with-copilot-engine
Environment="PATH={{ project_dir }}/venv/bin"
EnvironmentFile={{ project_dir }}/app/coco-testai-with-copilot-engine/.env

ExecStart={{ project_dir }}/venv/bin/celery -A coco_testai worker \
    --loglevel=info \
    --concurrency=4 \
    --max-tasks-per-child=100

Restart=always
RestartSec=10s

StandardOutput=append:{{ project_dir }}/logs/celery-worker.log
StandardError=append:{{ project_dir }}/logs/celery-worker.error.log

[Install]
WantedBy=multi-user.target
```

### Phase 3: CI/CD Pipeline Setup (Week 3-4)

**Step 3.1: GitHub Actions Workflow**

`.github/workflows/deploy-infrastructure.yml`:
```yaml
name: Deploy Infrastructure

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        type: choice
        options:
          - test
          - demo
          - prod
      cloud_provider:
        description: 'Cloud provider'
        required: true
        type: choice
        options:
          - aws
          - azure
      action:
        description: 'Terraform action'
        required: true
        type: choice
        options:
          - apply
          - destroy

jobs:
  terraform:
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.6.0

      - name: Configure AWS credentials
        if: github.event.inputs.cloud_provider == 'aws'
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Configure Azure credentials
        if: github.event.inputs.cloud_provider == 'azure'
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Terraform Init
        run: |
          cd terraform/environments/${{ github.event.inputs.environment }}
          terraform init

      - name: Terraform Plan
        run: |
          cd terraform/environments/${{ github.event.inputs.environment }}
          terraform plan \
            -var="cloud_provider=${{ github.event.inputs.cloud_provider }}" \
            -out=tfplan

      - name: Terraform Apply
        if: github.event.inputs.action == 'apply'
        run: |
          cd terraform/environments/${{ github.event.inputs.environment }}
          terraform apply -auto-approve tfplan

      - name: Terraform Destroy
        if: github.event.inputs.action == 'destroy'
        run: |
          cd terraform/environments/${{ github.event.inputs.environment }}
          terraform destroy -auto-approve \
            -var="cloud_provider=${{ github.event.inputs.cloud_provider }}"

      - name: Export Terraform Outputs
        if: github.event.inputs.action == 'apply'
        run: |
          cd terraform/environments/${{ github.event.inputs.environment }}
          terraform output -json > outputs.json
          echo "BACKEND_IPS=$(terraform output -json instance_ips | jq -r '.[]')" >> $GITHUB_ENV

      - name: Update Ansible Inventory
        if: github.event.inputs.action == 'apply'
        run: |
          cd ansible/inventories/${{ github.event.inputs.environment }}
          python3 ../../scripts/update_inventory.py \
            --terraform-output ../../../terraform/environments/${{ github.event.inputs.environment }}/outputs.json \
            --cloud-provider ${{ github.event.inputs.cloud_provider }}

      - name: Commit inventory changes
        if: github.event.inputs.action == 'apply'
        run: |
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git add ansible/inventories/${{ github.event.inputs.environment }}/hosts.ini
          git commit -m "Update ${{ github.event.inputs.environment }} inventory" || echo "No changes"
          git push
```

`.github/workflows/deploy-backend.yml`:
```yaml
name: Deploy Backend

on:
  push:
    branches:
      - main
      - demo
      - test
    paths:
      - 'coco-testai-with-copilot-engine/**'
      - 'ansible/**'
      - '.github/workflows/deploy-backend.yml'

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Determine environment
        id: env
        run: |
          if [ "${{ github.ref }}" == "refs/heads/main" ]; then
            echo "environment=prod" >> $GITHUB_OUTPUT
          elif [ "${{ github.ref }}" == "refs/heads/demo" ]; then
            echo "environment=demo" >> $GITHUB_OUTPUT
          else
            echo "environment=test" >> $GITHUB_OUTPUT
          fi

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'

      - name: Install Ansible
        run: |
          python -m pip install --upgrade pip
          pip install ansible boto3 botocore

      - name: Configure SSH key
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.SSH_PRIVATE_KEY }}" > ~/.ssh/deploy_key
          chmod 600 ~/.ssh/deploy_key
          eval $(ssh-agent -s)
          ssh-add ~/.ssh/deploy_key

      - name: Run Ansible deployment
        env:
          ANSIBLE_HOST_KEY_CHECKING: False
        run: |
          cd ansible
          ansible-playbook \
            -i inventories/${{ steps.env.outputs.environment }}/hosts.ini \
            playbooks/backend-deploy.yml \
            -e "deploy_branch=${{ github.ref_name }}" \
            -e "cloud_provider=${{ secrets.CLOUD_PROVIDER }}" \
            --private-key ~/.ssh/deploy_key

      - name: Run smoke tests
        run: |
          sleep 30  # Wait for services to start
          curl -f https://api-${{ steps.env.outputs.environment }}.cocotestai.com/api/health/ \
            || exit 1

      - name: Notify deployment status
        if: always()
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: 'Backend deployment to ${{ steps.env.outputs.environment }}: ${{ job.status }}'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### Phase 4: Monitoring & Rollback (Week 4)

**Step 4.1: Health Check Endpoints**

Already exists in backend: `/api/health/`

**Step 4.2: Rollback Playbook**

`ansible/playbooks/rollback.yml`:
```yaml
---
- name: Rollback Backend Deployment
  hosts: backend_servers
  become: yes

  vars:
    project_dir: "/opt/coco-testai"
    rollback_commit: "{{ rollback_to_commit }}"

  tasks:
    - name: Stop all services
      systemd:
        name: "{{ item }}"
        state: stopped
      loop:
        - coco-daphne
        - coco-grpc-agent
        - coco-celery-worker
        - coco-celery-beat
        - coco-pg-listener

    - name: Checkout previous version
      git:
        repo: "{{ git_repo }}"
        dest: "{{ project_dir }}/app"
        version: "{{ rollback_commit }}"
        force: yes
      become_user: coco

    - name: Run migrations backward (if needed)
      django_manage:
        command: "migrate {{ rollback_migration }}"
        app_path: "{{ project_dir }}/app/coco-testai-with-copilot-engine"
        virtualenv: "{{ project_dir }}/venv"
      become_user: coco
      when: rollback_migration is defined

    - name: Start all services
      systemd:
        name: "{{ item }}"
        state: started
      loop:
        - coco-daphne
        - coco-grpc-agent
        - coco-celery-worker
        - coco-celery-beat
        - coco-pg-listener
```

**Usage:**
```bash
ansible-playbook \
  -i inventories/prod/hosts.ini \
  playbooks/rollback.yml \
  -e "rollback_to_commit=abc123def456"
```

---

## Cloud Provider Comparison

### AWS Services

| Component | Service | Cost Estimate (prod) |
|-----------|---------|---------------------|
| Compute | EC2 t3.xlarge x2 | $240/month |
| Database | RDS PostgreSQL db.t3.large | $150/month |
| Cache | ElastiCache Redis (cache.t3.medium) | $80/month |
| Storage | S3 Standard (500GB) | $12/month |
| CDN | CloudFront (500GB transfer) | $42/month |
| Load Balancer | ALB | $25/month |
| DNS | Route53 Hosted Zone | $0.50/month |
| SSL | ACM (Free) | $0/month |
| **Total** | | **~$550/month** |

### Azure Services

| Component | Service | Cost Estimate (prod) |
|-----------|---------|---------------------|
| Compute | Azure VM Standard_D4s_v3 x2 | $280/month |
| Database | Azure Database for PostgreSQL (GP) | $170/month |
| Cache | Azure Cache for Redis (Standard C1) | $75/month |
| Storage | Blob Storage (500GB) | $10/month |
| CDN | Azure CDN (500GB transfer) | $40/month |
| Load Balancer | Azure Load Balancer | $20/month |
| DNS | Azure DNS Zone | $0.50/month |
| SSL | Azure Key Vault | $3/month |
| **Total** | | **~$600/month** |

**Note:** Costs are estimates for production environment. Actual costs may vary based on usage.

---

## Migration Strategy

### From Current AWS Setup to New System

**Current State:**
- Webapp: Manual S3 + CloudFront deployment via GitHub Actions
- Backend: Manual SSH deployment to EC2

**Target State:**
- Webapp: Automated via CI/CD (no change)
- Backend: Automated via Terraform + Ansible

**Migration Steps:**

1. **Create Terraform state for existing resources (Import)**
   ```bash
   cd terraform/environments/prod
   terraform import aws_instance.backend i-0abc123def456
   terraform import aws_db_instance.postgres coco-testai-postgres
   # ... import all resources
   ```

2. **Test deployment on demo environment first**
   ```bash
   # Deploy demo from scratch
   cd terraform/environments/demo
   terraform apply
   cd ../../ansible
   ansible-playbook -i inventories/demo playbooks/backend-deploy.yml
   ```

3. **Parallel run (existing prod + new demo)**
   - Run both for 1 week
   - Compare metrics, errors, performance

4. **Cutover to new system**
   - Blue-green deployment: spin up new prod infrastructure
   - Migrate database (pg_dump/restore)
   - Switch DNS to new environment
   - Monitor for 24 hours
   - Decommission old infrastructure

### From AWS to Azure (Future)

**Scenario:** Customer wants deployment on Azure

**Steps:**

1. **Update Terraform variables**
   ```hcl
   # terraform/environments/prod/terraform.tfvars
   cloud_provider = "azure"  # Change from "aws"
   ```

2. **Run Terraform apply**
   ```bash
   terraform apply -var="cloud_provider=azure"
   ```

3. **Configure Azure-specific secrets**
   - Azure Storage connection string
   - Azure Key Vault references
   - Service Principal credentials

4. **Run Ansible deployment**
   ```bash
   ansible-playbook \
     -i inventories/prod \
     playbooks/backend-deploy.yml \
     -e "cloud_provider=azure"
   ```

5. **Migrate data**
   - Database: pg_dump from AWS RDS → Azure Database for PostgreSQL
   - Storage: `aws s3 sync` → `az storage blob upload-batch`

**Estimated Time:** 1-2 days for infrastructure, 1 day for data migration

---

## Security Considerations

### 1. Secrets Management

**Current Approach:** `.env` files (insecure for production)

**Recommended:**
- AWS: AWS Secrets Manager or Parameter Store
- Azure: Azure Key Vault

**Implementation:**
```python
# settings/production.py
import boto3
from botocore.exceptions import ClientError

def get_secret(secret_name):
    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager', region_name='us-east-1')
    try:
        secret_value = client.get_secret_value(SecretId=secret_name)
        return secret_value['SecretString']
    except ClientError as e:
        raise e

SECRET_KEY = get_secret('coco-testai/django-secret-key')
DODO_PAYMENTS_API_KEY = get_secret('coco-testai/dodo-api-key')
DODO_WEBHOOK_SECRET = get_secret('coco-testai/dodo-webhook-secret')
```

### 2. Network Security

**Firewall Rules (Security Groups / NSGs):**
```hcl
# Allow HTTPS from anywhere
ingress {
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# Allow SSH from bastion only
ingress {
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  security_groups = [var.bastion_sg_id]
}

# Allow PostgreSQL from backend servers only
ingress {
  from_port       = 5432
  to_port         = 5432
  protocol        = "tcp"
  security_groups = [var.backend_sg_id]
}
```

### 3. SSL/TLS

**Let's Encrypt with Certbot (Ansible):**
```yaml
- name: Install Certbot
  apt:
    name:
      - certbot
      - python3-certbot-nginx
    state: present

- name: Obtain SSL certificate
  command: >
    certbot --nginx
    -d api.cocotestai.com
    -d api-demo.cocotestai.com
    --non-interactive
    --agree-tos
    --email admin@cocotestai.com
```

### 4. IAM/RBAC

**AWS IAM Role for EC2:**
- S3 read/write for artifacts bucket
- Secrets Manager read for secrets
- CloudWatch Logs write for logging

**Azure Managed Identity:**
- Storage Account Contributor for blob storage
- Key Vault Secrets User for secrets
- Log Analytics Contributor for monitoring

---

## Monitoring & Observability

### 1. Application Monitoring

**Recommended Tools:**
- **APM:** DataDog, New Relic, or Azure Application Insights
- **Logging:** CloudWatch Logs / Azure Monitor Logs
- **Error Tracking:** Sentry (already in use?)

**Django Integration:**
```python
# settings/production.py
LOGGING = {
    'version': 1,
    'handlers': {
        'cloudwatch': {
            'class': 'watchtower.CloudWatchLogHandler',
            'log_group': '/aws/ec2/coco-testai-backend',
            'stream_name': 'django-app',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['cloudwatch'],
            'level': 'INFO',
        },
    },
}
```

### 2. Infrastructure Monitoring

**Metrics to Track:**
- CPU, Memory, Disk usage (EC2/VM)
- Database connections, query latency (RDS/Azure DB)
- Redis memory usage, evictions
- Load balancer request count, latency
- CDN cache hit ratio

**Alerts:**
- CPU > 80% for 5 minutes
- Disk usage > 85%
- Database connections > 80% of max
- Error rate > 1% of requests
- Response time p95 > 2 seconds

### 3. Health Checks

**Backend Health Endpoint:**
```python
# views.py
from django.http import JsonResponse
from django.db import connection

def health_check(request):
    checks = {
        'database': False,
        'redis': False,
        'celery': False,
    }

    # Database check
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
        checks['database'] = True
    except Exception:
        pass

    # Redis check
    try:
        from django.core.cache import cache
        cache.set('health_check', 'ok', 1)
        checks['redis'] = cache.get('health_check') == 'ok'
    except Exception:
        pass

    # Celery check
    try:
        from celery import current_app
        inspect = current_app.control.inspect()
        workers = inspect.active()
        checks['celery'] = bool(workers)
    except Exception:
        pass

    all_healthy = all(checks.values())
    status_code = 200 if all_healthy else 503

    return JsonResponse(checks, status=status_code)
```

**Load Balancer Configuration:**
```hcl
# AWS ALB Target Group
resource "aws_lb_target_group" "backend" {
  health_check {
    path                = "/api/health/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }
}
```

---

## Disaster Recovery

### 1. Backup Strategy

**Database:**
- Automated daily backups (RDS/Azure DB native)
- Retention: 7 days
- Cross-region replication for prod

**Storage:**
- S3 versioning enabled
- Lifecycle policy: Move to Glacier after 90 days
- Azure Blob: Soft delete enabled (30 days)

**Application Code:**
- Git repository is source of truth
- Tagged releases for each deployment

### 2. Recovery Procedures

**Scenario 1: Database Corruption**
```bash
# AWS RDS restore from snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier coco-testai-postgres-restored \
  --db-snapshot-identifier coco-testai-postgres-snapshot-2026-03-01
```

**Scenario 2: Region Failure**
- DNS failover to standby region (Route53 health checks)
- Database: Promote read replica to master
- Storage: S3 cross-region replication already active

**Scenario 3: Bad Deployment**
```bash
# Rollback using Ansible
ansible-playbook \
  -i inventories/prod \
  playbooks/rollback.yml \
  -e "rollback_to_commit=$(git rev-parse HEAD~1)"
```

### 3. RTO/RPO Targets

| Scenario | RTO (Recovery Time) | RPO (Data Loss) |
|----------|-------------------|-----------------|
| Application crash | < 5 minutes | 0 (auto-restart) |
| Bad deployment | < 15 minutes | 0 (rollback) |
| Database corruption | < 1 hour | < 15 minutes |
| Region failure | < 4 hours | < 5 minutes |
| Complete disaster | < 24 hours | < 1 hour |

---

## Cost Optimization

### 1. Right-Sizing

**Current Recommendations:**
- Start with t3.large instead of t3.xlarge for demo/test
- Use Spot Instances for test execution (Kubernetes nodes)
- Burstable instances (t3/B-series) for variable workloads

### 2. Auto-Scaling

**EC2 Auto Scaling Group:**
```hcl
resource "aws_autoscaling_group" "backend" {
  min_size         = 2
  max_size         = 10
  desired_capacity = 2

  target_group_arns = [aws_lb_target_group.backend.arn]

  tag {
    key                 = "Name"
    value               = "coco-backend"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu_scaling" {
  autoscaling_group_name = aws_autoscaling_group.backend.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}
```

### 3. Reserved Instances

**For stable prod workload:**
- 1-year reserved instances save ~30%
- 3-year reserved instances save ~50%
- Consider Savings Plans for flexibility

### 4. Storage Optimization

**S3 Lifecycle Policies:**
```hcl
resource "aws_s3_bucket_lifecycle_configuration" "artifacts" {
  rule {
    id     = "archive-old-artifacts"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}
```

---

## Testing Strategy

### 1. Infrastructure Testing

**Terraform Validation:**
```bash
terraform fmt -check
terraform validate
tflint
```

**Terraform Testing with Terratest:**
```go
// test/terraform_aws_test.go
func TestTerraformAWS(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../terraform/environments/test",
        Vars: map[string]interface{}{
            "cloud_provider": "aws",
        },
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    instanceIPs := terraform.OutputList(t, terraformOptions, "instance_ips")
    assert.NotEmpty(t, instanceIPs)
}
```

### 2. Ansible Testing

**Molecule Framework:**
```yaml
# molecule/default/molecule.yml
platforms:
  - name: backend-test
    image: geerlingguy/docker-ubuntu2204-ansible

provisioner:
  name: ansible
  playbooks:
    converge: ../../playbooks/backend-deploy.yml

verifier:
  name: testinfra
```

**Testinfra Verification:**
```python
# molecule/default/tests/test_backend.py
def test_systemd_services(host):
    services = [
        'coco-daphne',
        'coco-celery-worker',
        'nginx',
    ]
    for service in services:
        s = host.service(service)
        assert s.is_running
        assert s.is_enabled

def test_health_endpoint(host):
    response = host.run("curl -f http://localhost:8000/api/health/")
    assert response.rc == 0
```

### 3. Smoke Tests

**Post-Deployment Checks:**
```bash
#!/bin/bash
# smoke-test.sh

BASE_URL="https://api.cocotestai.com"

# Health check
curl -f $BASE_URL/api/health/ || exit 1

# Login endpoint
curl -f $BASE_URL/api/auth/login/ || exit 1

# Test authenticated request
TOKEN=$(curl -s -X POST $BASE_URL/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"testpass"}' \
  | jq -r .access_token)

curl -f -H "Authorization: Bearer $TOKEN" \
  $BASE_URL/api/conversations/ || exit 1

echo "✅ All smoke tests passed"
```

---

## Deployment Checklist

### Pre-Deployment

- [ ] Update `terraform.tfvars` with correct values
- [ ] Set cloud provider credentials in GitHub Secrets
- [ ] Update DNS records (if needed)
- [ ] Backup production database
- [ ] Review Terraform plan output
- [ ] Notify team of deployment window

### During Deployment

- [ ] Run Terraform apply
- [ ] Verify infrastructure creation
- [ ] Run Ansible deployment
- [ ] Verify all systemd services running
- [ ] Run smoke tests
- [ ] Check application logs

### Post-Deployment

- [ ] Monitor error rates for 1 hour
- [ ] Verify credit system working
- [ ] Test critical user journeys
- [ ] Check database migrations applied
- [ ] Verify WebSocket connections
- [ ] Update documentation if needed
- [ ] Notify team deployment complete

### Rollback Criteria

Rollback if any of these occur within 1 hour:
- Error rate > 5%
- Response time p95 > 5 seconds
- Database connection failures
- Critical feature broken
- Data integrity issues

---

## Timeline

### Week 1: Infrastructure Setup
- [ ] Create Terraform modules (compute, database, cache, storage, network)
- [ ] Test on demo environment (AWS)
- [ ] Document Terraform usage

### Week 2: Ansible Configuration
- [ ] Create Ansible roles and playbooks
- [ ] Test on demo environment
- [ ] Create systemd service templates

### Week 3: CI/CD Pipeline & Multi-Environment CLI
- [ ] Create GitHub Actions workflows
- [ ] Build multi-environment CLI tool (`deploy-cli.sh`)
- [ ] Implement environment creation/destruction scripts
- [ ] Set up secrets management
- [ ] Test end-to-end deployment on demo
- [ ] Test creating/destroying dynamic environments

### Week 4: Azure Support
- [ ] Add Azure provider to Terraform modules
- [ ] Test deployment on Azure (test environment)
- [ ] Document Azure-specific configurations

### Week 5: Production Migration
- [ ] Import existing AWS resources to Terraform
- [ ] Parallel run (old + new system)
- [ ] Cutover to new deployment system
- [ ] Decommission old infrastructure

### Week 6: Monitoring & Documentation
- [ ] Set up monitoring dashboards
- [ ] Configure alerting
- [ ] Write runbooks
- [ ] Team training on new system

---

## Success Metrics

### Deployment Frequency
- **Current:** Manual, ~1-2 times/month
- **Target:** Automated, multiple times/day

### Deployment Time
- **Current:** 2-4 hours (manual SSH, service restarts)
- **Target:** < 20 minutes (automated pipeline)

### Failure Rate
- **Target:** < 5% of deployments require rollback

### Recovery Time
- **Current:** 1-2 hours (manual investigation + fix)
- **Target:** < 15 minutes (automated rollback)

### Cloud Flexibility
- **Current:** AWS-only, migration would take weeks
- **Target:** Switch to Azure in < 2 days

---

## Future Enhancements

### Phase 2: Containerization (Q2 2026)
- Dockerize backend application
- Deploy to ECS (AWS) or AKS (Azure)
- Use managed Kubernetes for test execution

### Phase 3: Multi-Region (Q3 2026)
- Deploy to multiple regions for lower latency
- Database cross-region replication
- GeoDNS routing

### Phase 4: GitOps (Q4 2026)
- Use ArgoCD or Flux for continuous deployment
- Git as single source of truth for infrastructure
- Automated drift detection and remediation

---

## Architecture Decisions & Best Practices

This deployment system is built following **2024-2026 DevOps industry best practices** as recommended by leading cloud providers and infrastructure-as-code communities.

### Configuration Management Philosophy

**Decision: External YAML Configuration Files**

Rather than hardcoding infrastructure presets in bash scripts, we use external YAML configuration files. This aligns with modern DevOps practices:

**Industry Evidence:**
1. **Kubernetes** - Uses YAML for all configuration ([Configuration Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/))
2. **AWS CloudFormation** - Supports YAML/JSON templates with IDE integration ([CloudFormation 2025 Year in Review](https://aws.amazon.com/blogs/devops/aws-cloudformation-2025-year-in-review/))
3. **Terraform Ecosystem** - Tools like Terragrunt, Terramate emphasize DRY configurations ([Top Terraform Tools 2025](https://www.bytebase.com/blog/top-terraform-tools/))
4. **GitOps Standard** - Atlantis and similar tools require version-controlled configs ([Terraform Automation](https://developer.hashicorp.com/terraform/tutorials/automation/automate-terraform))

**Key Advantages:**
- ✅ **Version Control** - Track infrastructure decisions in Git with clear diffs
- ✅ **Validation** - JSON Schema validation catches errors before deployment
- ✅ **IDE Support** - VSCode/IntelliJ YAML extensions provide autocomplete and validation
- ✅ **Accessibility** - Non-developers (DevOps, managers) can modify without bash knowledge
- ✅ **GitOps Workflows** - Pull requests for infrastructure changes, reviewable diffs
- ✅ **Separation of Concerns** - Logic (bash) separate from data (YAML)
- ✅ **Scalability** - Add new presets without modifying code
- ✅ **Security** - Tools like Gitleaks scan for hardcoded secrets ([DevOps CLI Tools](https://dev.to/globalping/top-10-cli-tools-for-devops-teams-4fok))

**Trade-offs:**
- ⚠️ Requires `yq` (YAML processor) - widely available, 2MB binary
- ⚠️ Slightly slower parsing - negligible for CLI tools (<100ms)

### Tooling Choices

**YQ (YAML Processor):**
- Industry-standard YAML CLI tool
- Used by Kubernetes, Helm, GitOps workflows
- Cross-platform (Linux, macOS, Windows)
- Actively maintained (v4.30+)

**JQ (JSON Processor):**
- De facto standard for JSON processing
- Required for Terraform output parsing
- Available in all major package managers

**Terraform + Ansible:**
- **Terraform** - Infrastructure provisioning (immutable infrastructure)
- **Ansible** - Configuration management (application deployment)
- Standard pattern: [Terraform Modules Best Practices 2025](https://americanchase.com/terraform-modules-best-practices/)

**GitHub Actions:**
- Native GitHub integration
- No external CI/CD infrastructure
- Free for public repos, generous limits for private

### Security Considerations

**Secrets Management:**
- AWS Secrets Manager / Azure Key Vault for production secrets
- Never commit secrets to Git (enforced by `.gitignore` and pre-commit hooks)
- Environment-specific secret namespaces: `coco-testai/{env}/{secret-name}`

**Configuration Validation:**
- JSON Schema validation before deployment
- Terraform plan review in pull requests
- Pre-deployment checks via GitHub Actions

**Least Privilege:**
- Separate IAM roles per environment
- Read-only access for developers
- Deployment credentials only in CI/CD

### DRY (Don't Repeat Yourself) Principle

Following [Terragrunt's DRY philosophy](https://www.bytebase.com/blog/top-terraform-tools/):

**Reusable Terraform Modules:**
```
terraform/modules/    ← Single implementation
terraform/environments/    ← Multiple configurations using same modules
```

**Reusable Ansible Roles:**
```
ansible/roles/    ← Single implementation
ansible/playbooks/    ← Multiple playbooks using same roles
```

**Shared Configuration:**
```
scripts/config/size-presets.yaml    ← Single source of truth
terraform/environments/*/terraform.tfvars    ← Reference presets
```

### Validation Pipeline

Automated validation at multiple stages:

1. **Pre-commit** - Local validation before git commit
   - YAML syntax check (`yamllint`)
   - Terraform format check (`terraform fmt`)
   - Ansible syntax check (`ansible-lint`)

2. **Pull Request** - CI validation before merge
   - JSON Schema validation
   - Terraform plan (dry-run)
   - Security scanning (Checkov, tfsec)

3. **Pre-deployment** - Final check before apply
   - Terraform plan approval required
   - Manual approval gate for production

4. **Post-deployment** - Verification
   - Health check endpoints
   - Smoke tests
   - Automated rollback on failure

### Cost Optimization Strategy

Following [Infracost best practices](https://www.bytebase.com/blog/top-terraform-tools/):

**Cost Awareness:**
- Every preset includes estimated monthly cost
- Terraform changes show cost impact before apply
- Monthly cost reports per environment
- Billing alerts at 50%, 80%, 90% of budget

**Right-Sizing:**
- Start with smaller presets (t3.medium)
- Scale up based on actual usage metrics
- Auto-scaling for variable workloads
- Scheduled shutdown for non-prod environments (optional)

**Reserved Instances (Production):**
- 1-year Reserved Instances save ~30%
- 3-year Reserved Instances save ~50%
- Evaluate after 3 months of stable usage

### References

**Official Documentation:**
- [Kubernetes Configuration Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [AWS CloudFormation 2025 Year in Review](https://aws.amazon.com/blogs/devops/aws-cloudformation-2025-year-in-review/)
- [HashiCorp Terraform Automation](https://developer.hashicorp.com/terraform/tutorials/automation/automate-terraform)

**Industry Tools:**
- [Top 5 Open Source Terraform Tools for 2025](https://www.bytebase.com/blog/top-terraform-tools/)
- [5 Terraform Tools You Should Know About in 2025](https://overmind.tech/blog/5-terraform-tools-you-should-know-about-in-2025)
- [Top 10 CLI Tools for DevOps Teams](https://dev.to/globalping/top-10-cli-tools-for-devops-teams-4fok)

**Best Practices:**
- [20 Terraform Modules Best Practices in 2025](https://americanchase.com/terraform-modules-best-practices/)
- [Building Terraform Wrappers with Python](https://dasroot.net/posts/2026/01/building-terraform-wrappers-python/)
- [10 Must-Have Tools for Terraform Productivity](https://www.devopstraininginstitute.com/blog/10-must-have-tools-for-terraform-productivity)

---

## Appendix

### A. Required GitHub Secrets

```yaml
# AWS
AWS_ACCESS_KEY_ID: <aws-access-key>
AWS_SECRET_ACCESS_KEY: <aws-secret-key>
AWS_REGION: us-east-1

# Azure
AZURE_CREDENTIALS: |
  {
    "clientId": "<client-id>",
    "clientSecret": "<client-secret>",
    "subscriptionId": "<subscription-id>",
    "tenantId": "<tenant-id>"
  }

# Cloud Provider Selection
CLOUD_PROVIDER: aws  # or azure

# Deployment
SSH_PRIVATE_KEY: <ssh-private-key-for-ansible>

# Notifications
SLACK_WEBHOOK: <slack-webhook-url>
```

### B. Useful Commands

```bash
# Terraform
terraform plan -var-file=terraform.tfvars
terraform apply -auto-approve
terraform destroy
terraform output
terraform state list

# Ansible
ansible-playbook -i inventories/prod playbooks/backend-deploy.yml --check
ansible-playbook -i inventories/prod playbooks/backend-deploy.yml --tags=deploy
ansible-playbook -i inventories/prod playbooks/rollback.yml -e "rollback_to_commit=abc123"

# AWS CLI
aws ec2 describe-instances --filters "Name=tag:Project,Values=Coco TestAI"
aws rds describe-db-instances --db-instance-identifier coco-testai-postgres
aws s3 sync dist/ s3://coco-artifacts-prod/

# Azure CLI
az vm list --resource-group coco-testai-prod
az postgres server show --name coco-testai-postgres --resource-group coco-testai-prod
az storage blob upload-batch -d artifacts -s dist/
```

### C. Troubleshooting

**Issue: Terraform apply fails with "already exists" error**
```bash
# Import existing resource
terraform import aws_instance.backend i-0abc123def456
```

**Issue: Ansible fails with SSH connection timeout**
```bash
# Check security group allows SSH from GitHub Actions runner
# Add GitHub Actions IP ranges to security group
```

**Issue: Database migration fails**
```bash
# Connect to server and run manually
ssh coco@backend-server
cd /opt/coco-testai/app/coco-testai-with-copilot-engine
source ../../venv/bin/activate
python manage.py migrate --verbosity=3
```

**Issue: Services not starting after deployment**
```bash
# Check service logs
journalctl -u coco-daphne -n 100
journalctl -u coco-celery-worker -n 100

# Check environment variables loaded
systemctl show coco-daphne | grep Environment
```

### D. Multi-Environment CLI Commands

**Create new environment:**
```bash
# Using helper script
./scripts/deploy-cli.sh create uat --cloud aws --size medium

# Manual (copy template)
cp -r terraform/environments/demo terraform/environments/uat
nano terraform/environments/uat/terraform.tfvars
```

**List all environments:**
```bash
./scripts/deploy-cli.sh list

# Or manually
ls terraform/environments/
```

**Deploy environment:**
```bash
# Via CLI
./scripts/deploy-cli.sh deploy uat

# Via GitHub Actions
# Actions → "Deploy Infrastructure" → Select environment → Run
```

**Get environment info:**
```bash
./scripts/deploy-cli.sh info uat

# Output shows:
# - Instance IPs
# - Database endpoint
# - Redis endpoint
# - S3 bucket name
# - URLs
# - Estimated monthly cost
```

**Scale environment:**
```bash
# Increase instance count
./scripts/deploy-cli.sh scale uat --instances 3

# Change instance size
cd terraform/environments/uat
nano terraform.tfvars  # Change instance_type
terraform apply
```

**Clone environment:**
```bash
# Clone demo to create uat (same config)
./scripts/deploy-cli.sh clone demo uat

# Clone with size adjustment
./scripts/deploy-cli.sh clone demo uat --size small
```

**Destroy environment:**
```bash
# Via CLI (with confirmation)
./scripts/deploy-cli.sh destroy uat

# Via Terraform (no confirmation)
cd terraform/environments/uat
terraform destroy -auto-approve
```

**View environment costs:**
```bash
# All environments
./scripts/deploy-cli.sh costs

# Specific environment
./scripts/deploy-cli.sh costs uat
```

**SSH into environment:**
```bash
# SSH to first instance
./scripts/deploy-cli.sh ssh uat

# SSH to specific instance
./scripts/deploy-cli.sh ssh uat --instance 2
```

**View environment logs:**
```bash
# All services
./scripts/deploy-cli.sh logs uat

# Specific service
./scripts/deploy-cli.sh logs uat --service daphne
./scripts/deploy-cli.sh logs uat --service celery-worker
```

**Compare environments:**
```bash
# Compare configurations
./scripts/deploy-cli.sh diff demo uat

# Shows differences in:
# - Instance types
# - Instance counts
# - Database configurations
# - Environment variables
```

---

## Conclusion

This deployment automation plan provides a **reusable, cloud-agnostic, and maintainable** solution for deploying ANY Django/Node.js/React application to AWS or Azure. Following 2026 industry best practices, the system is designed as a **separate repository** that can be used across multiple projects.

**Architecture:** Two-Repository Pattern ([HashiCorp Standard](https://developer.hashicorp.com/terraform/tutorials/modules/pattern-module-creation))
- ✅ `multi-cloud-deployer` - Reusable deployment system (separate repo)
- ✅ Application repos (e.g., `coco-testai`) - Application code + deployment config

**Key Benefits:**

**Reusability:**
1. **Use for any application** - Django, Node.js, React, or fullstack apps
2. **Independent versioning** - Deployer v1.0, v1.1, v2.0 separate from application versions
3. **Maintain once** - Update deployer, all projects benefit
4. **Open source potential** - Can make deployer public while keeping apps private

**Deployment:**
5. **Zero manual deployment** - Push code, CI/CD handles the rest
6. **Cloud flexibility** - Switch between AWS and Azure with configuration change
7. **Unlimited environments** - Create test, staging, UAT, feature environments on-demand
8. **Fast recovery** - Automated rollback in < 15 minutes

**Operations:**
9. **Easy environment lifecycle** - Create/destroy environments in 10-15 minutes via CLI
10. **Consistent environments** - All use identical infrastructure templates
11. **Scalable** - Auto-scaling for traffic spikes
12. **Cost-effective** - Per-environment cost tracking and right-sizing

**Next Steps:**

### Phase 1: Create Deployer Repository (Week 1-2)
1. Create new repository: `multi-cloud-deployer`
2. Implement Terraform modules (compute, database, cache, storage, network)
3. Implement Ansible roles (python-django, nodejs, react-spa)
4. Create CLI tool with YAML configuration support
5. Add examples for common application types
6. Write documentation (README, QUICKSTART, CONFIGURATION)

### Phase 2: Configure Coco TestAI (Week 3)
1. Create new repository: `coco-testai-infrastructure`
2. Add `.deployer/` directory structure
3. Create `repos.yaml` referencing backend and frontend repos
4. Create `config.yaml` with Coco TestAI configuration
5. Create environment configs (prod.yaml, demo.yaml, test.yaml)
6. Test deployment to demo environment
7. Validate all services work correctly (backend + frontend integration)

### Phase 3: Production Deployment (Week 4-5)
1. Deploy to production environment
2. Monitor for 1 week
3. Fine-tune configuration based on metrics
4. Document any Coco TestAI-specific customizations

### Phase 4: Open Source (Optional)
1. Clean up code, add comprehensive documentation
2. Add LICENSE (MIT or Apache 2.0)
3. Create CONTRIBUTING.md guide
4. Publish `multi-cloud-deployer` to GitHub
5. Share with developer community

**Future Applications:**

Once `multi-cloud-deployer` is built and installed globally, deploying a new application is simple:

**Example 1: Monorepo Application (Simple)**
```bash
# New Django app in a monorepo
cd my-django-app
mkdir -p .deployer/environments

cat > .deployer/config.yaml <<EOF
project:
  name: "my-app"
  type: "backend"
components:
  backend:
    type: "python-django"
    root_dir: "."
infrastructure:
  database:
    engine: "postgres"
EOF

cloud-deploy create prod --preset medium --cloud aws
cloud-deploy up prod
```

**Example 2: Separate FE/BE Repos (Like Coco TestAI)**
```bash
# Create infrastructure repo
mkdir my-app-infrastructure
cd my-app-infrastructure
mkdir -p .deployer/environments

# Reference separate frontend/backend repos
cat > .deployer/repos.yaml <<EOF
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
EOF

cat > .deployer/config.yaml <<EOF
project:
  name: "my-app"
  type: "fullstack"
components:
  backend:
    type: "python-django"
  frontend:
    type: "react-vite"
infrastructure:
  database:
    engine: "postgres"
  cache:
    engine: "redis"
EOF

cloud-deploy create prod --preset medium --cloud aws
cloud-deploy up prod
```

**This deployment system will serve you for years across multiple projects!** 🚀
