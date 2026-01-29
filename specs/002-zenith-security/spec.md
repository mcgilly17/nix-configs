# Feature Specification: Zenith Cluster Security Hardening

**Feature Branch**: `002-zenith-security`
**Created**: 2026-01-28
**Status**: Draft
**Input**: Security concerns about Tailscale lateral movement, secrets exposure, and container breakout risks

## Executive Summary

The Zenith k3s cluster (zenith-1/2/3) and sephiroth dev server are operational but lack defense-in-depth security measures. A compromised server could potentially:
- Pivot to other devices via Tailscale
- Read decrypted secrets from /run/secrets
- Join rogue nodes to the k3s cluster
- Escape containers to access host resources

This spec defines a comprehensive security hardening plan.

---

## Current State Diagnosis

### Infrastructure
- 4 RK1 ARM64 nodes on Turing Pi 2 cluster
- 1 dev server (sephiroth) - NixOS with full dev tools
- 3 k3s cluster nodes (zenith-1 control plane, zenith-2/3 agents)
- All running NixOS with declarative configs
- Connected via Tailscale VPN

### Current Security Measures
| Measure | Status | Notes |
|---------|--------|-------|
| SSH key-only auth | ✅ Done | Password auth disabled |
| Root account locked | ✅ Done | `hashedPassword = "!"` |
| PermitRootLogin | ✅ Done | Set to "no" |
| Basic firewall | ✅ Done | Default NixOS firewall |
| SOPS-nix secrets | ✅ Done | Age keys from SSH host keys |
| Traefik disabled | ✅ Done | Will install own ingress |
| ServiceLB disabled | ✅ Done | Will use MetalLB |

### Security Gaps

| Gap | Risk Level | Description |
|-----|------------|-------------|
| No Tailscale ACLs | 🔴 Critical | All devices can reach all devices |
| Secrets at rest readable | 🔴 Critical | /run/secrets readable by root |
| Static K3s join token | 🔴 High | Token never rotates |
| No pod security standards | 🔴 High | Containers run with excessive privileges |
| No network policies | 🟡 Medium | Pods can communicate freely |
| No audit logging | 🟡 Medium | No record of security events |
| No runtime security | 🟡 Medium | No container behavior monitoring |
| No file integrity monitoring | 🟡 Medium | Config changes undetected |

---

## Threat Model

### Realistic Attack Vectors

| Vector | Likelihood | Impact | Description |
|--------|------------|--------|-------------|
| Exposed Service Exploitation | Medium | Critical | Vulnerable container workload exposed to internet |
| Supply Chain Attack | Medium | High | Malicious container image or Nix package |
| Credential Theft | Low-Medium | Critical | SSH key or Tailscale auth key compromise |
| Physical Access | Low | Critical | Direct access to Turing Pi board |
| Lateral Movement via Tailscale | Low | High | Compromised node pivots to other tailnet devices |
| Container Breakout | Low | Critical | Escape from container to host |
| K3s API Exploitation | Low | Critical | Unauthenticated or over-privileged API access |

### Attack Scenarios

1. **Scenario A: Compromised Container** - Attacker exploits vulnerability in AI/ML workload, escapes container, accesses node secrets
2. **Scenario B: Stolen SSH Key** - Developer laptop compromised, attacker uses SSH key to access nodes
3. **Scenario C: Malicious Image** - Pulled container image contains backdoor, exfiltrates data
4. **Scenario D: K3s Token Theft** - Attacker obtains cluster join token, adds rogue node

---

## User Concerns (Verbatim)

1. "If someone gets into the server then they can use tailscale to then get into so many other devices"
2. "Have we removed all secrets? Can they not just re-build?"
3. "They could edit the configs"
4. "The only things exposed will be docker containers running software"

---

## Security Requirements

### R1: Tailscale Network Segmentation
**Priority**: P0 (Critical)

Servers MUST NOT be able to:
- SSH to each other
- SSH to admin devices (laptop, PC, phone)
- Access any device except explicitly allowed k3s cluster ports

Admin devices (laptop, PC, phone) MUST be able to:
- Access each other freely
- SSH to all servers
- Access k3s API

**Implementation**: Tailscale ACLs with device tags

### R2: Secrets Protection
**Priority**: P0 (Critical)

- Secrets in /run/secrets MUST have 0400 permissions
- K3s secrets MUST be encrypted at rest
- Age private keys MUST be protected from container access
- Consider external secrets operator for sensitive workloads

### R3: K3s Cluster Security
**Priority**: P1 (High)

- Pod Security Standards MUST be enforced (restricted by default)
- Network Policies MUST default to deny-all
- RBAC MUST follow least-privilege principle
- Service accounts MUST NOT auto-mount tokens
- K3s API MUST have audit logging enabled

### R4: Node Hardening
**Priority**: P1 (High)

- Kernel hardening parameters MUST be applied
- Unused kernel modules MUST be blacklisted
- SSH MUST only listen on Tailscale interface
- Firewall MUST only allow necessary ports
- File integrity monitoring SHOULD be enabled

### R5: Container Security
**Priority**: P1 (High)

- Containers MUST run as non-root
- Containers MUST have read-only root filesystem
- Containers MUST drop all capabilities by default
- Containers MUST have resource limits
- Container images SHOULD be scanned for vulnerabilities

### R6: Detection & Response
**Priority**: P2 (Medium)

- Security events MUST be logged centrally
- Failed SSH attempts SHOULD trigger alerts
- File integrity changes SHOULD trigger alerts
- K3s audit logs SHOULD be aggregated

---

## Proposed Tailscale ACL Policy

```json
{
  "tagOwners": {
    "tag:admin": ["michael@example.com"],
    "tag:k3s": ["michael@example.com"],
    "tag:server": ["michael@example.com"]
  },

  "acls": [
    // Admins (laptop, PC, phone) can access everything
    {
      "action": "accept",
      "src": ["tag:admin"],
      "dst": ["*:*"]
    },

    // K3s nodes can talk to each other on cluster ports only (NOT SSH)
    {
      "action": "accept",
      "src": ["tag:k3s"],
      "dst": [
        "tag:k3s:6443",
        "tag:k3s:10250",
        "tag:k3s:8472/udp",
        "tag:k3s:2379-2380"
      ]
    },

    // Servers can reach internet for updates
    {
      "action": "accept",
      "src": ["tag:k3s", "tag:server"],
      "dst": ["autogroup:internet:*"]
    }

    // IMPLICIT DENY: servers cannot reach admin devices or SSH to each other
  ],

  "ssh": [
    {
      "action": "accept",
      "src": ["tag:admin"],
      "dst": ["tag:k3s", "tag:server"],
      "users": ["michael", "root"]
    }
  ]
}
```

**Tag Assignments**:
- `tag:admin`: Laptop, PC, Phone
- `tag:k3s`: zenith-1, zenith-2, zenith-3
- `tag:server`: sephiroth

---

## Implementation Phases

### Phase 1: Quick Wins (This Week)
| Task | Effort | Impact |
|------|--------|--------|
| Implement Tailscale ACLs | 1 hour | Critical |
| Enable K3s secrets encryption | 30 min | High |
| Apply Pod Security Standards | 1 hour | High |
| Restrict /run/secrets permissions | 15 min | Medium |
| Enable K3s audit logging | 30 min | Medium |

### Phase 2: Core Hardening (Next 2 Weeks)
| Task | Effort | Impact |
|------|--------|--------|
| Implement network policies | 2 hours | High |
| NixOS kernel hardening | 1 hour | Medium |
| SSH hardening (algorithms, Tailscale-only) | 30 min | Medium |
| K3s token rotation mechanism | 1 hour | Medium |
| AIDE file integrity monitoring | 1 hour | Medium |

### Phase 3: Advanced Security (Next Month)
| Task | Effort | Impact |
|------|--------|--------|
| Centralized logging (Vector/Loki) | 4 hours | Medium |
| Container image scanning in CI | 2 hours | Medium |
| Fail2ban for SSH | 30 min | Low |
| Security alerting (webhook) | 2 hours | Medium |
| RBAC audit for workloads | 2 hours | Medium |

### Phase 4: Optional Enhancements
| Task | Effort | Impact | Notes |
|------|--------|--------|-------|
| HashiCorp Vault | 1 day | Medium | Only if processing sensitive data |
| Secure boot | 1 day | Medium | ARM64 support varies |
| Falco runtime security | 4 hours | Medium | Adds resource overhead |
| Immutable root filesystem | 2 days | High | Complex setup |

---

## Acceptance Criteria

### Tailscale Segmentation
- [ ] ACL policy deployed to Tailscale admin console
- [ ] zenith nodes tagged with `tag:k3s`
- [ ] sephiroth tagged with `tag:server`
- [ ] Admin devices tagged with `tag:admin`
- [ ] Verified: zenith-1 CANNOT ssh to laptop
- [ ] Verified: zenith-1 CAN reach zenith-2 on port 6443
- [ ] Verified: laptop CAN ssh to all servers

### K3s Security
- [ ] Secrets encryption enabled (`--secrets-encryption`)
- [ ] Audit logging enabled
- [ ] Pod Security Standards enforced on production namespace
- [ ] Default-deny NetworkPolicy in production namespace
- [ ] Verified: new pod without security context is rejected

### Node Hardening
- [ ] Kernel hardening sysctl parameters applied
- [ ] SSH listening only on Tailscale interface
- [ ] Firewall allows only required ports
- [ ] auditd enabled and logging

### Detection
- [ ] Security events aggregated to central location
- [ ] Alert on >10 failed SSH attempts/hour
- [ ] AIDE baseline created and daily checks scheduled

---

## Files to Create/Modify

### New Files
- `modules/nixos/security/hardening.nix` - Kernel and system hardening
- `modules/nixos/security/audit.nix` - Audit logging configuration
- `modules/nixos/security/firewall.nix` - Strict firewall rules
- `kubernetes/security/pod-security-standards.yaml` - PSS policies
- `kubernetes/security/network-policies.yaml` - Default deny policies

### Modifications
- `hosts/nixos/rk1/common/default.nix` - Import security modules
- `hosts/nixos/rk1/zenith-1/default.nix` - K3s security flags
- `modules/nixos/tailscale.nix` - Add shields-up, auth key support
- `modules/nixos/sops.nix` - Stricter permissions

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| ACL misconfiguration locks out admin | Test ACLs with `--dry-run`, keep emergency access method |
| Kernel hardening breaks k3s | Apply incrementally, test after each change |
| Pod Security Standards break workloads | Start with audit mode, then enforce |
| Audit logging fills disk | Set log rotation and size limits |

---

## References

- [Tailscale ACLs Documentation](https://tailscale.com/kb/1018/acls)
- [K3s Security Hardening Guide](https://docs.k3s.io/security/hardening-guide)
- [NixOS Security Options](https://nixos.org/manual/nixos/stable/#sec-security)
- [Kubernetes Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes)
