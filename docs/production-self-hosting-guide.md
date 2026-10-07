# Production self-hosting guide for an open-source AI agent platform

Deploy the open-source Kortix AI Management System on one Linux host with Docker Compose. The same stack runs on a VPS, a cloud VM, your VPC or an on-prem network.

Kortix runs as one Docker Compose stack that holds the control plane: accounts, projects, repos, secrets, connectors, policies and the audit trail. Agent sessions run on a separate sandbox provider and call back into the stack.

## Prerequisites

- A Linux host. [Self-hosted Kortix](https://kortix.com/self-hosted) lists 2 vCPU and 4 GB of RAM as the floor, and 4 vCPU and 16 GB for real use.
- Docker Engine with the Compose plugin.
- A DNS A/AAAA record for your domain and for `api.<domain>`, both pointing at the host.
- Ports 80 and 443 open, so Caddy can issue the TLS certificate.
- A sandbox provider key. Daytona is the default; Platinum and E2B are also supported.

## The compose stack

The generated `docker-compose.yml` defines the production services:

- `frontend` runs the web app.
- `kortix-api` runs the API and control plane.
- `llm-gateway` routes model calls through your own provider keys.
- `supabase-db`, `supabase-auth` and `supabase-rest` are Postgres, authentication and REST for the data plane.
- `caddy` is the reverse proxy on ports 80 and 443.

Start it with the Kortix CLI, which generates the Compose project and its `.env` under `~/.config/kortix/self-host/<instance>/`:

```bash
kortix self-host init --domain <domain> --email <email>
kortix self-host start
```

Set the sandbox provider key, and a managed-git token if you use one:

```bash
kortix self-host configure
```

Check the stack while it starts:

```bash
kortix self-host status
kortix self-host doctor
kortix self-host logs kortix-api
```

This repo ships the operational files around the CLI: a `Makefile` of thin wrappers over `kortix self-host`, `.env.example`, the `Caddyfile` and these docs. The Compose project and its `.env` live in the instance directory that `kortix self-host init` created.

## Reverse proxy and TLS

Caddy terminates TLS and renews certificates automatically. `Caddyfile` has one site block for `<domain>` and one for `api.<domain>`, each with an ACME email from `ACME_EMAIL`. A minimal shape:

```caddyfile
{$DOMAIN} {
	encode zstd gzip
	reverse_proxy frontend:3000
}

api.{$DOMAIN} {
	encode zstd gzip
	reverse_proxy kortix-api:8000
}
```

Keep ports 80 and 443 reachable from the internet for the challenge, or use DNS-01 if your host is behind a proxy. If you terminate TLS on your own load balancer, forward `X-Forwarded-Proto` and `X-Forwarded-For` to Caddy and keep the same hostnames.

## Secrets handling

- `.env` holds every secret and signing key the instance uses. Keep it out of git and set `chmod 600 .env`.
- Secrets are encrypted at rest with a key per project.
- Connector credentials are brokered server-side and never enter the sandbox.
- Model provider keys are stored as encrypted project secrets: `kortix providers set anthropic sk-ant-...`. List them with `kortix providers ls`.
- Rotate generated values with `kortix self-host env rotate`. List values masked with `kortix self-host env ls`, and add `--show` only when you need one.

## Backups

Kortix has no separate backup service. One instance stores its data in three places under `~/.config/kortix/self-host/<instance>/`:

- `volumes/db/data` holds the Postgres database.
- `volumes/storage` holds file storage.
- `.env` holds every secret and signing key.

Back up all three. For a live database, take a `pg_dump`:

```bash
docker compose exec -T supabase-db pg_dump -U postgres postgres | gzip > backup-$(date +%F).sql.gz
tar -czf storage-$(date +%F).tgz volumes/storage
```

`make backup` wraps those two commands. Copy the result off the host, keep the `.env` beside it, and run a restore test before you need one.

Restore by stopping the stack, putting the two directories and `.env` back, then running `kortix self-host start`.

## Upgrades and rollback

- Every instance updates itself once a day by default. The updater runs the migration, then starts the new services before it stops the old ones.
- Pin an exact version with `kortix self-host update --tag 0.9.84`.
- Turn automatic updates off with `kortix self-host update --auto-update off`.
- Roll back by pinning the previous tag with `kortix self-host update --tag <previous>`.
- Back up before every upgrade, and run `make backup` first.

## Health checks and monitoring

- `kortix self-host doctor` runs a full check; `kortix self-host status` reports service state.
- `docker compose ps` shows container state, and `docker stats --no-stream` shows memory.
- Each API container has a 640 MiB memory limit by default. Keep it on an 8 GiB host. On a 16 GiB host, raise it when API traffic hits the limit: `kortix self-host env set KORTIX_API_MEMORY_LIMIT=1024m`. Confirm with `docker stats --no-stream`.
- Watch free space on `volumes/db/data` and `volumes/storage`, and the age of the newest backup.
- Caddy renews TLS automatically. Alert if a certificate is within 14 days of expiry.
- Alert on `kortix-api` restart loops and on any `doctor` failure.

Next: [VPC and on-prem deployment](vpc-and-on-prem-deployment.md) and the [FAQ](faq.md).
