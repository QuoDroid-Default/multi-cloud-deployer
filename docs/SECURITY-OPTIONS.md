# Security Options for EC2 Instance Access

## Current Setup (Implemented)
**Option 1: Public IPs + Restricted SSH**
- EC2 instances in public subnets with public IPs
- SSH restricted to GitHub Actions IP ranges only
- HTTP/HTTPS open for testing
- **Cost**: FREE (no additional networking costs)
- **Use case**: Test environments

## Future Options for Production

### Option 4: Private Subnets + AWS Systems Manager (Recommended for Production)

**What is SSM Session Manager?**
- AWS service that provides secure shell access without SSH
- No need to manage SSH keys or bastion hosts
- Full audit logging of all sessions
- No inbound ports needed (all traffic is outbound)

**Architecture:**
- EC2 instances in private subnets (no public IPs)
- SSM Agent on instances (pre-installed on Ubuntu)
- IAM role attached to instances
- Either NAT Gateway OR VPC Endpoints for connectivity

**Cost Breakdown:**

**Option 4A: Private Subnets + NAT Gateway**
- NAT Gateway: ~$0.045/hour = **~$32-35/month**
- Data processing: $0.045/GB
- Pros: Instances can reach internet for updates
- Cons: Most expensive option

**Option 4B: Private Subnets + VPC Endpoints** (2026 Best Practice)
- VPC Endpoints needed:
  1. `com.amazonaws.{region}.ssm` - SSM service
  2. `com.amazonaws.{region}.ssmmessages` - Session Manager
  3. `com.amazonaws.{region}.ec2messages` - EC2 messaging
- Cost: ~$0.01/hour per endpoint × 3 = **~$21/month**
- No data processing charges for SSM traffic
- Pros: Cheaper, more secure
- Cons: No internet access (need S3 endpoint for updates)

**Security Benefits:**
- ✅ No SSH ports exposed
- ✅ No public IPs
- ✅ Full session logging to CloudWatch
- ✅ IAM-based access control
- ✅ MFA support
- ✅ No SSH key management

**Implementation Steps (For Later):**
1. Move instances to private subnets
2. Create IAM role with SSM permissions
3. Attach role to instances
4. Choose between NAT Gateway or VPC Endpoints
5. Update Ansible to use SSM connection plugin
6. Update security groups (remove SSH ingress)

### Option 3: Private Subnets + Bastion Host (Traditional Approach)

**Architecture:**
- EC2 instances in private subnets
- Single bastion host in public subnet with SSH
- SSH jump through bastion to reach private instances

**Cost:**
- Bastion instance: ~$5-15/month (t3.micro)
- NAT Gateway: ~$32-35/month
- **Total: ~$37-50/month**

**Pros:**
- Traditional, well-understood pattern
- Works with standard SSH tools
- Can use bastion for other admin tasks

**Cons:**
- Most expensive option
- Need to manage bastion host
- Single point of failure
- SSH key management complexity
- Less audit visibility than SSM

## Comparison Table

| Option | Cost/Month | Security | Complexity | Best For |
|--------|-----------|----------|------------|----------|
| **Option 1: Public + Restricted SSH** | $0 | Good | Low | Test environments |
| **Option 3: Bastion Host** | ~$40-50 | Very Good | Medium | Legacy systems |
| **Option 4A: SSM + NAT** | ~$32-35 | Excellent | Medium | Production with internet access |
| **Option 4B: SSM + VPC Endpoints** | ~$21 | Excellent | High | Production (2026 best practice) |

## Recommendation

- **Test/Demo**: Use Option 1 (current implementation)
- **Production**: Use Option 4B (SSM + VPC Endpoints)
- **Legacy Migration**: Use Option 3 (Bastion) if SSM not feasible

## GitHub Actions IP Ranges (for Option 1)

GitHub publishes IP ranges at: https://api.github.com/meta

Regularly update these ranges for security. As of 2026, use:
- `actions` IP ranges for GitHub-hosted runners
- Consider using self-hosted runners for consistent IPs

## Next Steps for Production Migration

1. Test SSM connectivity in test environment first
2. Set up CloudWatch logging for session audit
3. Document SSM access procedures for team
4. Plan migration window
5. Update Ansible playbooks to use SSM connection
6. Test deployment pipeline with SSM
7. Migrate production environment
8. Remove SSH access completely

## References

- [AWS Systems Manager Documentation](https://docs.aws.amazon.com/systems-manager/)
- [SSM Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)
- [VPC Endpoints for SSM](https://aws.amazon.com/premiumsupport/knowledge-center/ec2-systems-manager-vpc-endpoints/)
- [GitHub Actions IP Ranges](https://api.github.com/meta)
