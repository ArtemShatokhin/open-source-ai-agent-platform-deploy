# FAQ: deploying the open-source Kortix AI agent platform

Short answers to the questions teams ask before they deploy the open-source Kortix AI Management System.

## What is an open source AI agent platform?

An open source AI agent platform is software you can read, run and modify that builds and operates AI agents. Kortix is the open-source AI Management System: your agents, their skills, your company memory and every connector live in one git repo you own, each session runs on its own isolated Linux sandbox, and work lands only through a change request a person reviews.

## Is Kortix free to self-host?

Self-hosting Kortix is free. One Docker Compose stack runs the whole control plane on your host, VPC or on-prem network, and you pay only for the host and your model provider. The managed plans are separate: Kortix Cloud has a free plan with 200 credits each month and 1 project, and Team is $40/seat/month with 2,500 pooled credits per seat.

## Which models can I run?

Kortix runs any model with your keys. Connect Anthropic, OpenAI, Google, Groq, xAI, DeepSeek, Mistral, Bedrock or OpenRouter, or point the gateway at your own OpenAI-compatible endpoint. Pick the model per agent, per session or per message. A self-hosted instance routes every call through the gateway on your own box, and Kortix holds no credential in that path.

## Where do my secrets live?

Secrets live in your instance. On self-host, the `.env` file under `~/.config/kortix/self-host/<instance>/` holds every secret and signing key, beside the Postgres and storage directories. Secrets are encrypted at rest with a key per project, connector credentials stay brokered server-side, and you rotate generated values with `kortix self-host env rotate`.

## How do agents reach my tools?

Agents reach tools through connectors. Kortix wires 3,000+ apps plus any MCP, OpenAPI, GraphQL or HTTP API, and the platform brokers the credential server-side, so it never enters the sandbox. You scope which agent may touch which connector in `kortix.yaml`, and set each tool call to Allow, Ask or Block down to the arguments it was given.

## Can Kortix run on-prem?

Kortix runs on-prem as the same Docker Compose stack inside your network. The control plane, Postgres and storage sit on your subnet. The sandbox tier is the one external dependency, so a fully isolated topology moves it inside with the rest, scoped with the Kortix team. Enterprise deployments add SAML SSO, SCIM directory sync and audit logs.

## How do sessions and branches work?

Each session gets its own isolated Linux sandbox on its own branch, named after the session. The agent works there, installs and runs what it needs, and commits. Only what it commits survives. Thousands of sandboxes run in parallel on one configuration with no crossover, and each branch feeds work back through a change request.

## How does human review work?

Work reaches the default branch only through a change request. Merge is default-deny for agents: the agent opens the change request, and a person reads the diff and merges it. You can watch a session live, diff any change to an agent or a skill, and roll any part of the repo back.

## What does Kortix Cloud cost?

Kortix Cloud has a free plan with 200 credits each month and 1 project. Team is $40/seat/month with 2,500 pooled credits per seat and optional managed models. Agent Computer runtime and managed model usage draw from the same pool. Enterprise adds SAML SSO, SCIM, audit logs, an SLA, a DPA and Cloud, VPC or on-prem deployment. Prices are as published at [kortix.com/pricing](https://kortix.com/pricing), checked October 2026.

## How do I migrate between self-host and cloud?

Your company is a git repo and the images are the same, so the configuration moves with you. Point the Kortix CLI at the target host with `kortix hosts use selfhost` or `kortix hosts use cloud`. Back up the three instance files (Postgres, storage and `.env`) before moving data, and reconnect your model provider keys on the target.
