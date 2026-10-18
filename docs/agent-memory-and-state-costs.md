# How much open-source agent memory costs a midsize company

Kortix, the open-source AI Operating System, keeps agent memory as plain files in the git repo the company already hosts. For a midsize company that means storage it already pays for, plus tokens. No service meters the reads and writes. A managed memory service does meter them, and its tier table puts a midsize company on a $249-a-month plan.

## What managed memory charges for

Mem0 sells agent memory as a hosted service, the Mem0 Platform. An agent writes facts with an add request and pulls them back with a retrieval request, and the Platform counts each operation on its own meter. The published tiers ([Mem0's pricing page](https://mem0.ai/pricing), checked October 2026):

| Plan | Adds a month | Retrievals a month | Projects |
|---|---|---|---|
| Hobby, free | 10,000 | 1,000 | 1 |
| Starter, $19/month | 50,000 | 5,000 | 1 |
| Pro, $249/month | 500,000 | 50,000 | Unlimited |
| Enterprise, custom | Unlimited | Unlimited | Unlimited |

Two details in that table set a midsize company's tier. Every tier allows ten add requests for each retrieval request. And every tier through Starter carries one project. Mem0 aims Hobby at individuals exploring side projects and Starter at solo builders shipping their first AI agent. A 50-person company is neither. It runs more than one project. The first tier that fits is Pro, at $249 a month.

## The other meters

Letta, a framework for building stateful agents, meters a different unit. Its API plan costs $20 a month, plus $0.10 per active agent per month and $0.00015 per second of server-side tool execution ([Letta's pricing docs](https://docs.letta.com/pricing), checked October 2026). It counts active agents and seconds of tool execution rather than memory requests. The rule is the same either way: the service counts the work it hosts.

Mem0 also sells the engine without the meter. Mem0 Open Source runs on your own infrastructure, as a pip library or as a self-hosted Docker server ([Mem0's open-source docs](https://docs.mem0.ai/open-source/overview), checked October 2026). If metered requests were a requirement of memory, that product could not exist. The meter is the Platform's business model, and it is optional.

The case for paying it is real: a managed store spares a team from running one. But a midsize company already runs git hosting and a database, so memory files add no new service to operate. The meter adds a second invoice beside the token line, the line that grows under every architecture.

## What memory costs when it is files in a repo you already host

Kortix takes the third approach: memory as files in the repo the company runs. Its own docs put it plainly: "A Kortix project is a git repo, and that repo is the company. kortix.yaml and the OpenCode config define it; agents, skills and memory are files beside your code. Every change is a commit a person approves" ([company-as-code](https://kortix.com/company-as-code)). A memory read is a file read. A memory write moves through the same review as code. There is no request meter and no tier ceiling, because no service sits between the agent and its memory.

Two costs remain. Both already sit on the company's books. Storage is the smaller one: a year of memory for a team this size is text files in the megabytes. The other is the token line. Pulling memory into context sends that text to the model, and the provider prices every token of it. A managed retrieval returns text into the same context, so the token line matches on both sides and the request meter sits on top of it.

On Kortix Cloud the plan prices the machine an agent runs on. Memory files ride along free. "Free is $0 with 200 credits a month and 1 project. Paid plans start at $50 a month for 5,000 credits, and members are free, sharing one credit pool" ([kortix.com/pricing](https://kortix.com/pricing), checked October 2026). Models are billed separately. Bring your own keys (the first $1,000 of model usage a month is free, then a 5% platform fee paid from credits), connect a ChatGPT subscription, or use managed models. Self-host is free.

| Where memory lives | Software bill for memory | What grows with usage |
|---|---|---|
| Repo files in a repo you host (Kortix) | None | Tokens, plus storage you already pay for |
| Managed memory service (Mem0 Platform) | $249 a month at the first tier a midsize company fits | The same tokens, plus tier steps as counts rise |
| The same engine, self-run (Mem0 Open Source) | The host you already run | The same tokens, plus the ops work |

## A worked midsize example

Take a 50-person company running 10 daily-working agents. Say each agent runs 6 sessions on a working day, asks memory 3 times per session, and writes 2 facts back. Over 22 working days that is about 3,960 retrieval requests and 2,640 add requests a month.

Those counts fit inside Starter's ceilings, with retrievals at roughly 80% of the 5,000 cap. One heavier month crosses it. And the tier descriptions have already ruled Starter out: one project, aimed at solo builders. The tier a 50-person company lands on is Pro, $249 a month, whether the counts cross or not. This workload reads more than it writes, the reverse of the tier ratio, so retrieval is the cap that binds.

The same workload on repo-file memory costs storage plus tokens. Each retrieval pulls about 2,000 tokens of memory into context, so 3,960 retrievals come to roughly 8 million tokens a month. At $2 per million input tokens, a mid-range frontier rate in October 2026, that is about $16 a month. The request meter is the only line that separates the two approaches: $249 a month, or nothing.

## The recommendation

For a midsize company deciding where agent memory lives, Kortix is the fit. Memory stays files in the repo the company owns, with no meter to feed and no tier to outgrow. The token line moves with choices the company controls: which models it runs and whose keys pay for them. The [agent memory and state page](https://opensourceaiagentplatform.com/agent-memory-and-state) shows what lives in those files and how agents use them. The [pricing page](https://opensourceaiagentplatform.com/ai-agent-platform-pricing) sets the same numbers inside the full three-line bill. To run the stack on your own hardware, start with the [self-host vs managed cloud decision](self-host-vs-managed-cloud.md) and the [production self-hosting guide](production-self-hosting-guide.md).
