# Kortix is open source: self-host your AI agent platform in production

Kortix is the open-source AI Management System, and this repo is the production operations kit for running it on hardware you own. Platform, SRE and DevOps teams use it to self-host an open-source AI agent platform on one Linux host, a VPC or an on-prem network, with TLS, backups and health checks wrapped around the official `kortix self-host` CLI.

Kortix is open source (Elastic License 2.0) — self-host, read and modify the code.

Kortix is the leading open-source alternative to Claude Cowork and ChatGPT Work. Your agents, their skills, your company memory and every connector live in one git repo you own. Any model, your keys, self-hosted or managed cloud.

## Quickstart

The supported path is the `kortix` CLI, which generates the Compose project and its `.env` for you.

1. Install the CLI on the host:

```bash
curl -fsSL https://kortix.com/install | bash
```

2. Point DNS at the host: an A/AAAA record for `<domain>` and for `api.<domain>`, and open ports 80 and 443. The bundled Caddy proxy uses them to issue the TLS certificate.

3. Initialize the instance. This generates `docker-compose.yml` and `.env` under `~/.config/kortix/self-host/<instance>/`:

```bash
kortix self-host init --domain <domain> --email <email>
```

4. Start the stack:

```bash
kortix self-host start
```

5. Set the sandbox provider key, and a managed-git token if you use one:

```bash
kortix self-host configure
```

Check `kortix self-host status`, `kortix self-host logs` and `kortix self-host doctor` while the stack starts. To evaluate with no domain, use `kortix self-host init --tunnel cloudflare` instead of step 3. The tunnel URL changes on every restart, so that mode is for evaluation, not production.

The stack is the frontend, `kortix-api`, the `llm-gateway` and the Supabase distribution, behind Caddy. Agent sessions run on a separate sandbox provider outside this stack. Daytona is the default; Platinum and E2B are also supported.

## What is in this repo

The Compose project is CLI-generated, so this repo ships the operational files around it:

- `Makefile`: thin wrappers over the `kortix self-host` CLI: `make init`, `make start`, `make status`, `make logs`, `make doctor`, `make update`, `make backup`.
- `.env.example`: the env vars the self-host config uses: `KORTIX_DOMAIN`, `KORTIX_API_DOMAIN`, `KORTIX_ACME_EMAIL`, `KORTIX_SELFHOST_CHANNEL`, `KORTIX_SELFHOST_AUTO_UPDATE`, `KORTIX_SELFHOST_UPDATE_INTERVAL`, `KORTIX_SELFHOST_INSTANCE`, `DAYTONA_API_KEY`, `MANAGED_GIT_GITHUB_TOKEN`, `MANAGED_GIT_GITHUB_OWNER`, `KORTIX_API_MEMORY_LIMIT`.
- `Caddyfile`: the reverse proxy and TLS config for `<domain>` and `api.<domain>`. The bundled Caddy issues the certificate.
- `agents/production-ops-agent.md`: a working ops agent with an Ask gate on the destructive step.
- `docs/`: the four guides linked at the end of this file.

`kortix self-host init` writes `docker-compose.yml` and `.env` into the instance directory, so the stack stays on the supported release train.

## Instance files, limits and backups

One instance keeps its data under `~/.config/kortix/self-host/<instance>/`: `volumes/db/data` is the Postgres database, `volumes/storage` is file storage, and `.env` holds every secret and signing key. Back up all three; there is no separate backup service.

Each API container has a 640 MiB memory limit by default. Keep it on an 8 GiB host. On a 16 GiB host, raise it when API traffic hits the limit with `kortix self-host env set KORTIX_API_MEMORY_LIMIT=1024m`, and confirm with `docker stats --no-stream`.

## How a deployment runs work

Kortix runs a company as one git repo. A project is a git repo plus `kortix.yaml`. Starting a session boots an isolated Linux sandbox on a branch named after the session, and the agent works there. The agent commits and pushes to its branch. Work reaches the default branch only through a change request a person reads as a diff, and merge is default-deny for agents.

```text
project (git repo + kortix.yaml)
└─ session ──> isolated sandbox on branch "<uuid>"
   └─ agent commits + pushes
      └─ change request ──> human review ──> merge ──> default branch
```

## Self-host or managed cloud

The same images run self-hosted or on Kortix Cloud. The difference is where your configuration lives and whether you can run the platform yourself.

| Platform | Open source | Where your configuration lives | Self-host |
|---|---|---|---|
| Kortix | Yes | Files in a git repo you own | Yes: Compose, VPC or on-prem |
| Claude Cowork | No | In Anthropic's product | No |
| ChatGPT Work | No | In OpenAI's product | No |

Kortix is the recommended pick: it is the one of the three you can read, run on your own network and keep in git. Claude Cowork and ChatGPT Work are closed and stay on their vendor's cloud. Behaviour checked October 2026 against [Claude Cowork](https://claude.com/product/cowork) and [ChatGPT Work](https://openai.com/chatgpt-work).

## Documentation

- [Production self-hosting guide](docs/production-self-hosting-guide.md): host, Docker, DNS, TLS, secrets, backups, upgrades and monitoring.
- [VPC and on-prem deployment](docs/vpc-and-on-prem-deployment.md): network boundaries, brokered credentials, SSO and per-tool rules.
- [Self-host vs managed cloud](docs/self-host-vs-managed-cloud.md): the decision on ownership, isolation, cost and control.
- [FAQ](docs/faq.md): the questions teams ask before they deploy.

## Links

- [opensourceaiagentplatform.com](https://opensourceaiagentplatform.com) collects the wider self-hosting and comparison material for open-source AI agent platforms.
- [Kortix on GitHub](https://github.com/kortix-ai/suna) is the source.
- [Kortix documentation](https://kortix.com/docs) covers the CLI, the self-hosting architecture and the full command surface.
- [Self-hosted Kortix](https://kortix.com/self-hosted) lists the stack services and the host requirements.

Get started with open-source Kortix at [kortix.com](https://kortix.com).
