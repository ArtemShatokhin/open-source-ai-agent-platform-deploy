# VPC and on-prem deployment for open-source Kortix

Run the open-source Kortix AI Management System inside a VPC or an on-prem network. It is the same Docker Compose stack as the production guide, with the domain pointed at an internal address and the network boundaries closed around it.

Kortix keeps the control plane on your network: accounts, projects, repos, secrets, connectors, policies and the audit trail. Sessions run on a sandbox provider. For a fully isolated topology, the sandbox tier moves inside your network with the rest, scoped with the Kortix team.

## Network boundaries

- Ingress: ports 80 and 443 on an internal load balancer or the host, with an A/AAAA record for `<domain>` and `api.<domain>`.
- Control plane: `frontend`, `kortix-api`, `llm-gateway` and the Supabase data plane run on a private subnet. Postgres and storage have no public route.
- Egress: the host needs outbound access to the sandbox provider (Daytona, Platinum or E2B) and to your model provider. Restrict it with a NAT gateway and an allowlist.
- The sandbox provider is the one external dependency. A fully isolated topology moves the sandbox tier inside your network too.

## Why credentials never enter the machine

A session runs on an isolated Linux sandbox. The sandbox holds no connector credentials and no model provider keys. Kortix brokers connector credentials server-side: the agent calls a connector through the platform, and the platform attaches the credential outside the sandbox. Model calls route through the `llm-gateway` inside your stack. A compromised session cannot read a credential it never had.

Each connector reaches only the tools you wire, and you scope which agent may touch which connector in `kortix.yaml`:

```yaml
agents:
  production-ops:
    file: agents/production-ops-agent.md
    connectors:
      - slack
      - github
```

## SSO, roles and the audit trail

Enterprise deployments add SAML 2.0 single sign-on and SCIM 2.0 directory sync with Okta, Microsoft Entra and JumpCloud, plus advanced RBAC, groups and audit logs. Every action is attributable to a person or an agent. Because session work lands as a change request, the audit trail includes the diff a person reviewed before merge.

## Per-tool rules down to an argument

Kortix sets each tool call to Allow, Ask or Block, down to the arguments the call was given. An Ask holds the call until a person approves it, then the agent resumes. The rule lives with the agent, in its markdown frontmatter:

```yaml
# agents/production-ops-agent.md
permission:
  bash:
    "kortix self-host status": allow
    "kortix self-host doctor": allow
    "kortix self-host update*": ask
    "docker compose down*": ask
    "*": block
```

Set the destructive calls to Ask for a team that wants speed, or to Block for a locked-down instance where a person runs them by hand. Either way the credentials stay server-side, so an allow rule grants access to a tool and never exposes a secret.

## Secrets at rest

Secrets are encrypted at rest with a key per project. Connector credentials are brokered server-side and never enter the machine. Model provider keys are stored as encrypted project secrets and injected at session boot. Rotate generated values with `kortix self-host env rotate`.

Next: the [production self-hosting guide](production-self-hosting-guide.md) and the [FAQ](faq.md).
