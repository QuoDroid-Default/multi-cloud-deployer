# Security Options for EC2 Instance Access from GitHub Actions

**Document Version**: 2.0 (Updated with 2026 Best Practices)
**Last Updated**: 2026-03-05

---

## ⚠️ Current Issue

**Problem**: GitHub Actions runners have dynamic IP addresses that change with each run, making it challenging to maintain secure SSH access to EC2 instances.

**Current Workaround (NOT RECOMMENDED)**: Opening SSH (port 22) to `0.0.0.0/0` (all IP addresses)

**Why This is Bad**:
> "Sensitive services such as SSH should be restricted to known IP addresses. **Never** open port 22 to 0.0.0.0/0 (all IPs)"
>
> — AWS Cloud Security Remediation Guide

**Source**: [AWS Cloud Security Remediation - Open SSH](https://github.com/aquasecurity/cloud-security-remediation-guides/blob/master/en/aws/ec2/open-ssh.md)

---

## 2026 Best Practices (Ranked)

### ✅ Option 1: AWS Systems Manager Session Manager (MOST RECOMMENDED)

**This is the 2026 default recommendation** - eliminates SSH entirely.

#### What is Session Manager?

Session Manager provides secure node management without the need to:
- ❌ Open inbound ports (no port 22)
- ❌ Maintain bastion hosts
- ❌ Manage SSH keys
- ✅ Full session logging to S3 or CloudWatch
- ✅ IAM-based access control
- ✅ MFA support

#### Architecture

```
GitHub Actions Runner
        ↓ (HTTPS outbound only)
    AWS SSM API
        ↓
   EC2 Instance (private subnet, no SSH port open)
```

#### Cost Breakdown

**Option 1A: Session Manager + NAT Gateway**
- NAT Gateway: ~$0.045/hour = **~$32-35/month**
- Data processing: $0.045/GB
- **Pros**: Instances can reach internet for package updates
- **Cons**: Most expensive option

**Option 1B: Session Manager + VPC Endpoints** (2026 Best Practice)
- VPC Endpoints needed:
  1. `com.amazonaws.{region}.ssm` - SSM service
  2. `com.amazonaws.{region}.ssmmessages` - Session Manager
  3. `com.amazonaws.{region}.ec2messages` - EC2 messaging
  4. `com.amazonaws.{region}.s3` - S3 gateway endpoint (for package updates)
- Cost: ~$0.01/hour per endpoint × 3 = **~$21/month**
- S3 gateway endpoint: **FREE**
- **Pros**: Cheaper, more secure, no internet access
- **Cons**: Requires VPC endpoint configuration

#### GitHub Actions Implementation

**Method A: Using AWS SSM Send-Command (Recommended)**

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v2
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ap-south-1

- name: Deploy via SSM
  uses: peterkimzz/aws-ssm-send-command@v1
  with:
    aws-region: ap-south-1
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    instance-ids: ${{ steps.terraform.outputs.instance_ids }}
    working-directory: /opt/app
    command: |
      git pull origin main
      pip install -r requirements.txt
      systemctl restart app
      systemctl restart nginx
```

**Method B: Using Ansible with SSM Connection Plugin**

```yaml
# ansible.cfg
[defaults]
host_key_checking = False

[connection]
pipelining = True

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
```

```yaml
# inventory.ini
[app_servers]
i-0fb12fd419f21e447

[app_servers:vars]
ansible_connection=aws_ssm
ansible_aws_ssm_region=ap-south-1
ansible_python_interpreter=/usr/bin/python3
```

```yaml
# GitHub Actions workflow
- name: Deploy with Ansible via SSM
  run: |
    pip install ansible-core boto3 botocore
    ansible-galaxy collection install amazon.aws

    ansible-playbook \
      -i inventory.ini \
      playbook.yml \
      -e "ansible_connection=aws_ssm"
```

#### Terraform Configuration

```hcl
# IAM role for EC2 instances to use SSM
resource "aws_iam_role" "ssm_role" {
  name = "${var.environment}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.environment}-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

# Attach to EC2 instances
resource "aws_instance" "app" {
  # ... other configuration ...
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  # No need for SSH security group rule!
}

# VPC Endpoints (Option 1B - Recommended)
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]
}

# Security group for VPC endpoints
resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.environment}-vpc-endpoints-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

#### Security Benefits

- ✅ No SSH ports exposed to internet
- ✅ No public IPs needed
- ✅ Full session logging to CloudWatch
- ✅ IAM-based access control with MFA support
- ✅ No SSH key management
- ✅ Audit trail of all commands executed
- ✅ Works from anywhere (no VPN needed)

#### Sources

- [How to Set Up Session Manager for EC2 Access Without SSH (2026 Guide)](https://oneuptime.com/blog/post/2026-02-12-session-manager-ec2-access-without-ssh/view)
- [AWS SSM Send-Command - GitHub Marketplace](https://github.com/marketplace/actions/aws-ssm-send-command)
- [Building CI/CD Pipeline with GitHub Actions & AWS SSM](https://medium.com/@yashwanthtss7/building-a-ci-cd-pipeline-with-github-actions-aws-ssm-a-step-by-step-guide-fd1c811a2711)
- [AWS Systems Manager Session Manager Documentation](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)

---

### ✅ Option 2: Dynamic IP Whitelisting (Good Alternative)

**Use this if Session Manager doesn't work for your deployment tools.**

#### How It Works

Temporarily add the GitHub Actions runner's IP to the security group during the workflow, then remove it after deployment.

#### GitHub Actions Implementation

```yaml
name: Deploy with Dynamic IP Whitelisting

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ap-south-1

      - name: Get runner IP address
        id: ip
        uses: haythem/public-ip@v1.2

      - name: Add IP to security group
        run: |
          aws ec2 authorize-security-group-ingress \
            --group-id ${{ secrets.SECURITY_GROUP_ID }} \
            --protocol tcp \
            --port 22 \
            --cidr ${{ steps.ip.outputs.ipv4 }}/32

          echo "Added IP ${{ steps.ip.outputs.ipv4 }}/32 to security group"

      - name: Wait for security group to propagate
        run: sleep 10

      - name: Deploy via SSH
        run: |
          # Your SSH deployment commands
          ssh -i key.pem ubuntu@${{ secrets.EC2_IP }} "
            cd /opt/app
            git pull
            systemctl restart app
          "

      - name: Remove IP from security group
        if: always()  # Always run cleanup, even if previous steps fail
        run: |
          aws ec2 revoke-security-group-ingress \
            --group-id ${{ secrets.SECURITY_GROUP_ID }} \
            --protocol tcp \
            --port 22 \
            --cidr ${{ steps.ip.outputs.ipv4 }}/32 || true

          echo "Removed IP ${{ steps.ip.outputs.ipv4 }}/32 from security group"
```

#### Using GitHub Marketplace Actions (Simpler)

```yaml
- name: Add IP to AWS security group
  uses: sohelamin/aws-security-group-add-ip-action@master
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: 'ap-south-1'
    aws-security-group-id: ${{ secrets.SECURITY_GROUP_ID }}
    port: '22'
    to-port: '22'
    protocol: 'tcp'
    description: 'GitHub Actions'

- name: Deploy via SSH
  run: |
    # Your deployment commands

- name: Remove IP from security group
  if: always()
  uses: sohelamin/aws-security-group-remove-ip-action@master
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: 'ap-south-1'
    aws-security-group-id: ${{ secrets.SECURITY_GROUP_ID }}
    port: '22'
    to-port: '22'
    protocol: 'tcp'
```

#### Required IAM Permissions

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:DescribeSecurityGroups"
      ],
      "Resource": "arn:aws:ec2:*:*:security-group/sg-xxxxx"
    }
  ]
}
```

#### Security Best Practices

- ✅ Use /32 CIDR (single IP only)
- ✅ Always include cleanup step with `if: always()`
- ✅ Add timeout to prevent indefinite access
- ✅ Use least-privilege IAM policies scoped to specific security groups
- ✅ Store AWS credentials in GitHub Secrets
- ✅ Log all security group changes for audit

#### Cost

- **FREE** - No additional AWS costs
- Only uses standard EC2/security group features

#### Sources

- [Dynamically add GitHub Actions IP to AWS security group](https://kamrul.dev/dynamically-add-github-actions-ip-to-aws-security-group/)
- [Dynamic Actions IP Whitelisting - GitHub](https://github.com/hamzaaeell/dynamic-actions-ip-whitelisting)
- [AWS Security Group Add IP - GitHub Marketplace](https://github.com/marketplace/actions/aws-security-group-add-ip)
- [sohelamin/aws-security-group-add-ip-action](https://github.com/sohelamin/aws-security-group-add-ip-action)

---

### ❌ Option 3: GitHub Meta API (NOT RECOMMENDED)

**Why This Doesn't Work:**

#### The Problems

1. **Scale Issue**:
   - GitHub Actions has **2,584 IP addresses** (2,156 IPv4 + 428 IPv6)
   - AWS security groups have a **limit of 60 rules** per group
   - **Mathematically impossible** to whitelist all IPs

2. **Incomplete List**:
   - GitHub explicitly states the meta API list is **"not intended to be an exhaustive list"**
   - Actions have been observed running with IP addresses **outside the published ranges**
   - You will still get connection timeouts even with all listed IPs

3. **Change Frequency**:
   - GitHub makes changes to IP addresses frequently
   - Requires constant monitoring and updates
   - High maintenance burden

#### GitHub's Official Statement

> "The IP addresses GitHub uses can change over time. The meta IP list is not intended to be an exhaustive list, so discrepancies are expected."
>
> — GitHub Documentation

#### Alternative: GitHub Enterprise Cloud Larger Runners

If you're on GitHub Enterprise Cloud, you can use **larger runners with static IP ranges**, which makes firewall whitelisting reliable.

#### Sources

- [GitHub Actions IP Ranges Discussion](https://github.com/orgs/community/discussions/26442)
- [About GitHub's IP Addresses](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/about-githubs-ip-addresses)
- [Actions running with IP addresses outside published range](https://github.com/orgs/community/discussions/172480)

---

### ❌ Option 4: Opening SSH to 0.0.0.0/0 (NEVER DO THIS)

**Status**: ⛔ **EXPLICITLY DISCOURAGED**

#### Why This is Dangerous

- 🚨 Exposes SSH to the entire internet
- 🚨 Makes your instances vulnerable to brute force attacks
- 🚨 Violates security compliance standards (PCI-DSS, HIPAA, SOC 2)
- 🚨 Will trigger AWS Security Hub findings
- 🚨 Fails security audits

#### What AWS Says

> "Sensitive services such as SSH should be restricted to known IP addresses. Never open port 22 to 0.0.0.0/0 (all IPs)"

#### Mitigation (If You Must)

If you absolutely must use this approach temporarily:

1. ✅ Use strong SSH key authentication (4096-bit RSA minimum)
2. ✅ Disable password authentication completely
3. ✅ Install fail2ban to block brute force attempts
4. ✅ Enable CloudWatch logging for SSH access
5. ✅ Set up AWS GuardDuty for threat detection
6. ✅ Rotate SSH keys frequently
7. ✅ **Migrate to Session Manager as soon as possible**

#### Source

- [AWS Cloud Security Remediation - Open SSH](https://github.com/aquasecurity/cloud-security-remediation-guides/blob/master/en/aws/ec2/open-ssh.md)

---

### Option 5: Bastion Host (Traditional Approach)

**Status**: Legacy solution, superseded by Session Manager

#### Architecture

```
GitHub Actions → Bastion (public subnet) → App Servers (private subnet)
```

#### Cost

- Bastion instance: ~$5-15/month (t3.micro)
- NAT Gateway: ~$32-35/month (for private subnet internet access)
- **Total: ~$37-50/month**

#### Pros

- ✅ Traditional, well-understood pattern
- ✅ Works with standard SSH tools
- ✅ Can use bastion for other admin tasks
- ✅ No vendor lock-in

#### Cons

- ❌ Most expensive option
- ❌ Need to manage bastion host (patching, monitoring)
- ❌ Single point of failure
- ❌ SSH key management complexity
- ❌ Less audit visibility than SSM
- ❌ Additional security hardening required

#### When to Use

- Legacy systems that can't use SSM
- Compliance requirements for jump hosts
- Multi-cloud deployments (non-AWS tools)

---

## Comparison Table

| Option | Cost/Month | Security | Complexity | GitHub Actions Support | Best For | 2026 Recommendation |
|--------|-----------|----------|------------|----------------------|----------|---------------------|
| **Session Manager (NAT)** | $32-35 | ⭐⭐⭐⭐⭐ | Medium | ✅ Excellent | Production with internet | ✅ Recommended |
| **Session Manager (VPC Endpoints)** | $21 | ⭐⭐⭐⭐⭐ | High | ✅ Excellent | Production (best practice) | ✅ **BEST** |
| **Dynamic IP Whitelisting** | $0 | ⭐⭐⭐⭐ | Low-Medium | ✅ Good | Test/staging if SSM blocked | ✅ Good alternative |
| **Bastion Host** | $40-50 | ⭐⭐⭐ | Medium | ⚠️ Complex | Legacy migration | ⚠️ Legacy |
| **GitHub Meta API** | $0 | ⭐⭐ | High | ❌ Unreliable | N/A | ❌ Don't use |
| **Open to 0.0.0.0/0** | $0 | ⭐ | Very Low | ✅ Works | **NEVER** | ❌ **NEVER** |

---

## 2026 Recommendations

### For Test/Demo Environments

**Option**: Dynamic IP Whitelisting (Option 2)
- Zero cost
- Works with existing SSH-based deployment
- Simple to implement
- Acceptable security for non-production

**Implementation Priority**:
1. ✅ Use dynamic IP whitelisting immediately
2. 📅 Plan Session Manager migration for production

### For Production Environments

**Option**: Session Manager + VPC Endpoints (Option 1B)
- Best security posture
- Reasonable cost (~$21/month)
- No SSH keys to manage
- Full audit trail

**Migration Path**:
1. Test Session Manager in staging environment
2. Update Ansible to use SSM connection plugin
3. Set up CloudWatch logging
4. Create VPC endpoints
5. Move instances to private subnets
6. Remove SSH security group rules
7. Document SSM access procedures

### For Legacy Systems

**Option**: Dynamic IP Whitelisting (Option 2) or Bastion Host (Option 5)
- Use dynamic whitelisting if SSM incompatible
- Use bastion only if required by compliance
- Plan SSM migration roadmap

---

## Implementation Guide

### Quick Start: Dynamic IP Whitelisting (Option 2)

**Step 1**: Add to your GitHub Actions workflow

```yaml
- name: Whitelist runner IP
  id: whitelist
  uses: sohelamin/aws-security-group-add-ip-action@master
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: 'ap-south-1'
    aws-security-group-id: ${{ secrets.SECURITY_GROUP_ID }}
    port: '22'
    protocol: 'tcp'

- name: Deploy
  run: |
    # Your deployment commands

- name: Remove IP
  if: always()
  uses: sohelamin/aws-security-group-remove-ip-action@master
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: 'ap-south-1'
    aws-security-group-id: ${{ secrets.SECURITY_GROUP_ID }}
    port: '22'
    protocol: 'tcp'
```

**Step 2**: Add required IAM permissions (see Option 2 section)

**Step 3**: Store security group ID in GitHub Secrets

**Time to implement**: ~15 minutes

### Full Migration: Session Manager (Option 1B)

**Phase 1: Preparation (Week 1)**
1. Test SSM connectivity on non-production instance
2. Update IAM policies
3. Test Ansible SSM connection plugin
4. Document procedures

**Phase 2: Infrastructure (Week 2)**
1. Create private subnets
2. Set up VPC endpoints
3. Create security groups for endpoints
4. Test endpoint connectivity

**Phase 3: Application Migration (Week 3)**
1. Update Terraform to use SSM IAM role
2. Deploy to staging with SSM
3. Test full deployment pipeline
4. Update monitoring and logging

**Phase 4: Production Cutover (Week 4)**
1. Deploy SSM-enabled infrastructure
2. Update GitHub Actions workflows
3. Remove SSH security group rules
4. Verify audit logging
5. Document rollback procedure

**Time to implement**: ~4 weeks

---

## Monitoring and Audit

### Session Manager Logging

Enable session logging to track all access:

```hcl
resource "aws_ssm_document" "session_manager_prefs" {
  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Document to hold regional settings for Session Manager"
    sessionType   = "Standard_Stream"
    inputs = {
      s3BucketName                = aws_s3_bucket.session_logs.id
      s3KeyPrefix                 = "session-logs/"
      s3EncryptionEnabled         = true
      cloudWatchLogGroupName      = aws_cloudwatch_log_group.session_logs.name
      cloudWatchEncryptionEnabled = true
      cloudWatchStreamingEnabled  = true
      kmsKeyId                    = aws_kms_key.ssm.id
      runAsEnabled                = false
    }
  })
}
```

### CloudWatch Alarms

```hcl
resource "aws_cloudwatch_metric_alarm" "unauthorized_ssh_attempts" {
  alarm_name          = "${var.environment}-unauthorized-ssh"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnauthorizedAccess"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Sum"
  threshold           = "3"
  alarm_description   = "Alert on unauthorized SSH attempts"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]
}
```

---

## Security Compliance

### Standards Met by Session Manager

- ✅ **PCI-DSS**: Requirement 8.2 (Unique ID, MFA)
- ✅ **HIPAA**: Access logging and audit trail
- ✅ **SOC 2**: Identity and access management controls
- ✅ **NIST**: Least privilege access
- ✅ **CIS Benchmarks**: Secure remote access

### Standards Violated by Open SSH (0.0.0.0/0)

- ❌ **PCI-DSS**: Requirement 1.3.1 (restrict inbound access)
- ❌ **HIPAA**: Technical safeguards (164.312)
- ❌ **SOC 2**: Trust services criteria
- ❌ **CIS**: 5.2.15 (SSH access restriction)

---

## Troubleshooting

### Session Manager Not Connecting

1. **Check SSM Agent status**:
   ```bash
   sudo systemctl status amazon-ssm-agent
   ```

2. **Verify IAM role attached to instance**:
   ```bash
   aws ec2 describe-instances --instance-ids i-xxxxx --query 'Reservations[0].Instances[0].IamInstanceProfile'
   ```

3. **Check VPC endpoint connectivity** (if using Option 1B):
   ```bash
   nslookup ssm.ap-south-1.amazonaws.com
   ```

4. **Verify security group allows HTTPS (443) from VPC CIDR**

### Dynamic IP Whitelisting Timing Out

1. **Increase wait time after adding IP**:
   ```yaml
   - name: Wait for security group
     run: sleep 15  # Increase from 10
   ```

2. **Verify security group ID is correct**

3. **Check IAM permissions for ec2:AuthorizeSecurityGroupIngress**

4. **Ensure runner IP is actually whitelisted**:
   ```bash
   aws ec2 describe-security-groups --group-ids sg-xxxxx
   ```

---

## Cost Optimization Tips

1. **Use S3 Gateway Endpoint** (FREE) instead of NAT for S3 access
2. **Share VPC endpoints** across multiple environments
3. **Use PrivateLink endpoints** only in production
4. **Consider regional pricing** differences
5. **Monitor data transfer costs** for NAT Gateway

---

## References and Further Reading

### AWS Documentation
- [AWS Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)
- [Session Manager Plugin for GitHub Actions](https://docs.aws.amazon.com/systems-manager/latest/userguide/plugin-github.html)
- [VPC Endpoints for SSM](https://aws.amazon.com/premiumsupport/knowledge-center/ec2-systems-manager-vpc-endpoints/)

### 2026 Best Practice Articles
- [How to Set Up Session Manager for EC2 Access Without SSH (2026)](https://oneuptime.com/blog/post/2026-02-12-session-manager-ec2-access-without-ssh/view)
- [AWS SSM with GitHub Actions - Step-by-Step Guide](https://medium.com/@yashwanthtss7/building-a-ci-cd-pipeline-with-github-actions-aws-ssm-a-step-by-step-guide-fd1c811a2711)
- [Dynamically add GitHub Actions IP to AWS security group](https://kamrul.dev/dynamically-add-github-actions-ip-to-aws-security-group/)

### GitHub Resources
- [AWS SSM Send-Command - GitHub Marketplace](https://github.com/marketplace/actions/aws-ssm-send-command)
- [Dynamic Actions IP Whitelisting](https://github.com/hamzaaeell/dynamic-actions-ip-whitelisting)
- [AWS Security Group Add IP Action](https://github.com/marketplace/actions/aws-security-group-add-ip)

### Security Guidelines
- [AWS Cloud Security Remediation - Open SSH](https://github.com/aquasecurity/cloud-security-remediation-guides/blob/master/en/aws/ec2/open-ssh.md)
- [GitHub Actions IP Ranges](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/about-githubs-ip-addresses)
- [GitHub Actions IP Range Limitations](https://github.com/orgs/community/discussions/26442)

### Community Discussions
- [Not able to SSH to AWS instances using GitHub Actions](https://github.com/orgs/community/discussions/65352)
- [GitHub Actions IP Ranges for Whitelist](https://github.com/orgs/community/discussions/26884)

---

## Next Steps

### Immediate Actions (This Week)

1. ✅ Implement Dynamic IP Whitelisting for test environment
2. ✅ Remove 0.0.0.0/0 SSH access
3. ✅ Test deployment pipeline with whitelisting
4. ✅ Document new process for team

### Short-term (This Month)

1. 📅 Test Session Manager in non-production
2. 📅 Update Ansible playbooks for SSM
3. 📅 Create IAM policies for SSM
4. 📅 Document migration plan

### Long-term (This Quarter)

1. 📅 Migrate production to Session Manager
2. 📅 Implement VPC endpoints
3. 📅 Enable session logging and monitoring
4. 📅 Train team on SSM procedures
5. 📅 Remove all SSH access completely

---

**Document Maintained By**: Multi-Cloud Deployer Team
**Last Review Date**: 2026-03-05
**Next Review Date**: 2026-06-05
