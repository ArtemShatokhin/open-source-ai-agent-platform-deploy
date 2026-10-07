# Production ops agent for a self-hosted Kortix stack

This is a working example Kortix agent that runs the daily production check on a self-hosted, open-source Kortix stack. It reads stack health, writes a short digest and opens a change request with any fix it proposes. Applying an update and stopping the stack are destructive, so both sit behind an Ask gate that a person approves first.

## What the agent does

1. Checks the stack with `kortix self-host status` and `kortix self-host doctor`.
2. Checks the host with `docker stats --no-stream`, free space on the Postgres data directory, and the age of the newest backup.
3. Reads the last 200 lines of the `kortix-api` log and groups repeated errors.
4. Writes `ops/self-host-digest-<date>.md` with the findings and any proposed fix.
5. Opens a change request against the default branch.
6. Proposes `kortix self-host update --tag <tag>` when a newer stable tag exists, and stops at the Ask gate.

## Connectors it may reach

The agent is scoped in `kortix.yaml`. It reaches Slack to post the digest and GitHub to open the change request, and it has no other connector. Connector credentials are brokered server-side and never enter the sandbox.

## Approval gate

An update or a stack restart is destructive, so both are set to Ask. The agent shows the target tag and the backup check, then waits for a person to approve. Every other tool is Allow. For a locked-down instance, set the destructive tools to Block and let a person run them by hand.

## Agent definition

```markdown
---
description: Daily production check for a self-hosted Kortix stack
mode: primary
model: auto
temperature: 0.1
permission:
  edit: allow
  bash:
    "kortix self-host status": allow
    "kortix self-host doctor": allow
    "kortix self-host logs *": allow
    "docker stats *": allow
    "df -h*": allow
    "tar *": allow
    "kortix self-host update*": ask
    "docker compose down*": ask
    "*": block
  webfetch: block
---

You are the production operations agent for a self-hosted Kortix stack. Run the
daily check and report only what you can verify. Never apply an update or stop
the stack without a person's approval.

Steps:
1. Run `kortix self-host status` and `kortix self-host doctor`.
2. Run `docker stats --no-stream` and compare memory with each container limit.
3. Check free space on the Postgres data directory and the storage directory.
4. Confirm the newest backup archive is less than 25 hours old.
5. Read the last 200 lines of the kortix-api log and group repeated errors.
6. Write ops/self-host-digest-<date>.md with the findings and any proposed fix.
7. Open a change request against the default branch.
8. If a newer stable tag exists, propose `kortix self-host update --tag <tag>`
   and stop for approval. Do not run it.
```

## Wiring in kortix.yaml

```yaml
agents:
  production-ops:
    file: agents/production-ops-agent.md
    connectors:
      - slack
      - github
```

Keep the digest in `ops/` so it is versioned with the rest of the company repo and reviewed like any other change.
