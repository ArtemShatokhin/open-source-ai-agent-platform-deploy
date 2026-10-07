# Kortix self-host — Makefile for running open-source Kortix in production.
#
# Thin wrappers over the `kortix self-host` CLI. The supported self-host path
# is the Kortix CLI: `kortix self-host init` generates docker-compose.yml and
# its .env under ~/.config/kortix/self-host/<instance>/. These targets only
# call that CLI, so the generated stack stays the single source of truth.
#
# Usage:
#   make init DOMAIN=kortix.example.com EMAIL=ops@example.com
#   make start
#
# .RECIPEPREFIX is set so the file does not depend on hard tabs.
.RECIPEPREFIX = >

INSTANCE ?= default
DOMAIN ?=
EMAIL ?=

.PHONY: help init start status logs doctor configure update env backup restore

help:
> @echo "Kortix self-host wrappers:"
> @echo "  make init DOMAIN=<domain> EMAIL=<email>  generate compose + .env, point at the domain"
> @echo "  make start                              pull images and start the stack"
> @echo "  make status                             show stack state"
> @echo "  make logs                               follow the API logs"
> @echo "  make doctor                             run the self-host diagnostics"
> @echo "  make configure                          interactive sandbox-provider + git key prompt"
> @echo "  make update                             update to the latest release"
> @echo "  make env NAME=key VALUE=value           set one instance env var"
> @echo "  make backup                             archive instance data + .env"
> @echo "  make restore FILE=backup.tar.gz         stop, restore, start"

init:
> kortix self-host init --domain $(DOMAIN) --email $(EMAIL) --instance $(INSTANCE)

start:
> kortix self-host start --instance $(INSTANCE)

status:
> kortix self-host status --instance $(INSTANCE)

logs:
> docker compose logs -f kortix-api

doctor:
> kortix self-host doctor --instance $(INSTANCE)

configure:
> kortix self-host configure --instance $(INSTANCE)

update:
> kortix self-host update --instance $(INSTANCE)

env:
> @test -n "$(NAME)" || (echo "usage: make env NAME=key VALUE=value" >&2; exit 2)
> kortix self-host env set $(NAME)=$(VALUE) --instance $(INSTANCE)

# Back up the two data directories and the instance .env before any destructive
# command: volumes/db/data (Postgres) and volumes/storage (files), plus .env.
backup:
> @mkdir -p backups
> tar -czf backups/kortix-selfhost-$(INSTANCE)-$$(date +%Y%m%d-%H%M%S).tar.gz \
>   -C $$HOME/.config/kortix/self-host/$(INSTANCE) volumes/db/data volumes/storage .env
> @echo "backup written under backups/"

restore:
> @test -n "$(FILE)" || (echo "usage: make restore FILE=backup.tar.gz" >&2; exit 2)
> kortix self-host stop --instance $(INSTANCE)
> tar -xzf $(FILE) -C $$HOME/.config/kortix/self-host/$(INSTANCE)
> kortix self-host start --instance $(INSTANCE)
