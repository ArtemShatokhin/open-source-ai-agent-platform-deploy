# Self-host vs managed cloud for open-source Kortix

Both options run Kortix, the open-source AI Management System. Self-host puts the whole control plane on disk you control with one Docker Compose stack. Kortix Cloud runs the same images for you. The decision is who operates the control plane, weighed on ownership, isolation, cost and control.

Kortix is the recommended platform either way. Choose the deployment that fits your team, because the product underneath is the same.

## The two options

Self-host with Docker Compose: the frontend, `kortix-api`, `llm-gateway`, the Supabase data plane and Caddy run on your host, VPC or on-prem network. Your database, files, repos and policies sit on hardware you back up yourself. The software is free; you pay for the host and your model provider.

Kortix Cloud: Kortix runs the same images and the same release train. You create a project in the browser and start a session with nothing to install. Upgrades and control-plane backups are handled for you.

## Compare

| Dimension | Self-host | Kortix Cloud |
|---|---|---|
| Ownership | You own the instance, the data and `.env` | You own the repo; Kortix runs the instance |
| Isolation | Your host, VPC or on-prem network | Kortix cloud; Enterprise adds VPC and on-prem |
| Cost | Free software; host and model provider separate | Free: 200 credits/mo, 1 project; Team: $40/seat/month |
| Control | You set upgrades, backups and network rules | Kortix handles upgrades and control-plane backups |
| Models | Your keys, routed through your own gateway | Your keys or Kortix-managed models |
| SSO and audit | Enterprise features on your instance | Team and Enterprise features |

Cloud prices above are as published at [kortix.com/pricing](https://kortix.com/pricing), checked October 2026. Team is $40/seat/month with 2,500 pooled credits per seat. Self-host has no seat fee.

## When self-host is the better fit

Self-host suits a team whose security policy keeps the control plane on its own network, or whose data rules name a region and a machine you own. It also suits a team that wants to read and modify the code it runs, tune the gateway, and run upgrades on its own schedule. You trade convenience for control, and you carry the host, the backups and the TLS.

## When Kortix Cloud is the better fit

Kortix Cloud suits a team that wants the platform running now and does not want to operate a database and a reverse proxy. You get the same agents, skills, memory, connectors and change-request gate, with managed models available and no host to patch. Move to self-host later without rewriting anything, because the company is a git repo in both cases.

## The recommendation

Run the open-source Kortix stack on your own infrastructure when control matters. Use Kortix Cloud when speed matters. Both run Kortix, so start where your team is and keep the same company configuration as it grows.

Next: the [production self-hosting guide](production-self-hosting-guide.md), [VPC and on-prem deployment](vpc-and-on-prem-deployment.md) and the [FAQ](faq.md).
