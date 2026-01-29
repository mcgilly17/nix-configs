# Tasks: Zenith Cluster Security Hardening

## Phase 1: Quick Wins (Critical Priority)

- [ ] **1.1 Tailscale ACLs** - Implement ACL policy in Tailscale admin console
  - [ ] Create `tag:admin`, `tag:k3s`, `tag:server` tags
  - [ ] Apply tags to devices
  - [ ] Deploy ACL policy
  - [ ] Verify segmentation works

- [ ] **1.2 K3s Secrets Encryption** - Enable encryption at rest
  - [ ] Add `--secrets-encryption` flag to zenith-1
  - [ ] Rebuild and verify secrets are encrypted

- [ ] **1.3 Pod Security Standards** - Enforce restricted policy
  - [ ] Create production namespace with PSS labels
  - [ ] Test that insecure pods are rejected

- [ ] **1.4 Secrets Permissions** - Harden /run/secrets
  - [ ] Update sops.nix with 0400 permissions
  - [ ] Add tmpfiles rule for /run/secrets directory

- [ ] **1.5 K3s Audit Logging** - Enable API audit logs
  - [ ] Create audit policy file
  - [ ] Add audit flags to k3s config
  - [ ] Verify logs are generated

## Phase 2: Core Hardening

- [ ] **2.1 Network Policies** - Default deny in k8s
  - [ ] Create default-deny NetworkPolicy
  - [ ] Create allow-dns NetworkPolicy
  - [ ] Apply to production namespace

- [ ] **2.2 Kernel Hardening** - NixOS sysctl and modules
  - [ ] Create modules/nixos/security/hardening.nix
  - [ ] Add kernel parameters
  - [ ] Blacklist unused modules
  - [ ] Test k3s still functions

- [ ] **2.3 SSH Hardening** - Tailscale-only access
  - [ ] Restrict SSH to Tailscale interface
  - [ ] Enforce strong ciphers
  - [ ] Add Fail2ban

- [ ] **2.4 Firewall Hardening** - Strict rules
  - [ ] Create interface-specific rules
  - [ ] Allow only k3s ports on LAN
  - [ ] Allow only SSH on Tailscale
  - [ ] Log dropped packets

- [ ] **2.5 File Integrity Monitoring** - AIDE setup
  - [ ] Install AIDE
  - [ ] Create baseline
  - [ ] Schedule daily checks

## Phase 3: Detection & Response

- [ ] **3.1 Centralized Logging** - Vector/Loki
  - [ ] Deploy Vector on each node
  - [ ] Deploy Loki on sephiroth
  - [ ] Configure log aggregation

- [ ] **3.2 Security Alerting** - Webhook notifications
  - [ ] Create security-monitor service
  - [ ] Configure webhook endpoint
  - [ ] Test alerts

- [ ] **3.3 K3s Audit Log Aggregation**
  - [ ] Ship audit logs to Loki
  - [ ] Create dashboard for suspicious events

## Phase 4: Optional Enhancements

- [ ] **4.1 External Secrets Operator** - For sensitive workloads
- [ ] **4.2 Container Image Scanning** - Trivy in CI
- [ ] **4.3 Runtime Security** - Falco deployment
- [ ] **4.4 Immutable Root Filesystem** - Impermanence pattern

---

## Quick Reference: Commands

### Test Tailscale ACLs
```bash
# From zenith-1, this should FAIL:
tailscale ping laptop

# From laptop, this should SUCCEED:
tailscale ping zenith-1
ssh michael@zenith-1
```

### Verify K3s Secrets Encryption
```bash
sudo k3s secrets-encrypt status
```

### Test Pod Security Standards
```bash
# This should be rejected in restricted namespace:
kubectl run test --image=nginx --privileged -n production
```

### Check Audit Logs
```bash
sudo tail -f /var/log/kubernetes/audit.log
```
