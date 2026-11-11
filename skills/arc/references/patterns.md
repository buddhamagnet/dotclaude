# Arc patterns

Last researched: 2026-11-11

Caveats from the research run:
- The Udemy page returned HTTP 403. Course topics come from the instructor's own page.
- The OpenAI guide PDF would not parse. Claims marked (excerpt) rest on search excerpts.
- OTel GenAI span details are from search results and are unverified.
- The forward deployed engineer section rests on vendor sources only.
- Numbers marked (vendor) are the vendor's own figures. Re-test them on your own workload.

## Core principles

- Find the simplest solution. Add complexity only when measured results improve. https://www.anthropic.com/engineering/building-effective-agents
- Context is finite. Aim for the smallest set of high-signal tokens. Recall drops as context grows. https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- Put as much effort into the agent-computer interface as into a human UI. https://www.anthropic.com/engineering/building-effective-agents
- Start evals early with 20 to 50 real tasks. https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents
- Contain at the environment layer first, then steer the model. https://www.anthropic.com/research/how-we-contain-claude
- Harness workarounds for model weakness go stale. Retest each model release. https://www.anthropic.com/research/harness-design-long-running-apps
- Frameworks hide prompts. Know the code under them. https://www.anthropic.com/engineering/building-effective-agents

## Workflow or agent

- A workflow is predefined code paths. An agent lets the model direct its own steps and tools in a loop. https://www.anthropic.com/engineering/building-effective-agents
- Use a workflow for well-defined tasks that need predictability. Use an agent when you cannot hardcode the path. https://www.anthropic.com/engineering/building-effective-agents
- Try a deterministic solution first (excerpt). https://cdn.openai.com/business-guides-and-resources/a-practical-guide-to-building-agents.pdf
- Agents fit complex decisions, unwieldy rules and unstructured data (excerpt). https://cdn.openai.com/business-guides-and-resources/a-practical-guide-to-building-agents.pdf
- Start with one agent. Split as the tool count grows (excerpt). https://cdn.openai.com/business-guides-and-resources/a-practical-guide-to-building-agents.pdf
- Agents cost more and compound errors. Add max iterations and human checkpoints. https://www.anthropic.com/engineering/building-effective-agents
- Agents use about 4x the tokens of chat. Multi-agent uses about 15x. https://www.anthropic.com/engineering/multi-agent-research-system
- Multi-agent suits breadth-first, parallel, high-value work. It fits poorly when context is shared, dependencies are many, and for most coding. https://www.anthropic.com/engineering/multi-agent-research-system

## Pattern catalogue

- Prompt chaining. Use for cleanly decomposable tasks. Trades latency for accuracy. https://www.anthropic.com/engineering/building-effective-agents
- Routing. Use for distinct categories, such as easy questions to small models. https://www.anthropic.com/engineering/building-effective-agents
- Parallelization (sectioning or voting). Use for speed or confidence. A guardrail model can run beside the main call. https://www.anthropic.com/engineering/building-effective-agents
- Orchestrator-workers. Use when subtasks are not known in advance. Failure modes are vague briefs that cause duplicated work, and synchronous subagents that bottleneck. https://www.anthropic.com/engineering/multi-agent-research-system
- Evaluator-optimizer. Use when criteria are clear. Failure mode is a model grading its own work too leniently. Use a separate, calibrated evaluator. https://www.anthropic.com/research/harness-design-long-running-apps
- Autonomous loop. Use for open-ended tasks. Failure modes are declaring done early, trying to one-shot the app, and running out of context. https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents
- Long-running initializer plus progress file. Use a JSON feature list, one feature per session, and git commits. https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents
- Manager (specialists called as tools) versus handoff (one-way transfer) (excerpt). https://cdn.openai.com/business-guides-and-resources/a-practical-guide-to-building-agents.pdf
- Do not use multi-agent for low-value or cost-sensitive work. https://www.anthropic.com/engineering/multi-agent-research-system

## Tool and MCP design

- Build a few tools for high-impact workflows. Do not wrap every endpoint. Avoid overlap. Namespace by service. https://www.anthropic.com/engineering/writing-tools-for-agents
- Return high-signal fields. Offer a concise or detailed mode. Paginate. Make errors actionable. https://www.anthropic.com/engineering/writing-tools-for-agents
- Name params without ambiguity (user_id, not user). Describe each tool like a briefing for a new hire. https://www.anthropic.com/engineering/writing-tools-for-agents
- Make wrong arguments hard to pass. Requiring absolute paths fixed one agent's errors. https://www.anthropic.com/engineering/building-effective-agents
- Tool search helps with 10 or more tools, or over 10K tokens of definitions. 85% fewer tokens (vendor). https://www.anthropic.com/engineering/advanced-tool-use
- Tool examples, 1 to 5 per tool, raised complex-parameter accuracy from 72% to 90% (vendor). https://www.anthropic.com/engineering/advanced-tool-use
- Code execution with MCP cut one example from 150k to 2k tokens. It needs a sandbox. https://www.anthropic.com/engineering/code-execution-with-mcp
- MCP has hosts, clients and servers. Servers expose tools, resources and prompts. https://modelcontextprotocol.io/docs/learn/architecture
- The latest MCP spec is 2026-07-28. It is stateless per request. Sampling is deprecated. Tasks is an extension. Check which version your code targets. https://modelcontextprotocol.io/docs/learn/architecture
- Treat tool descriptions and annotations as untrusted unless the server is trusted. Get user consent before tool calls. https://modelcontextprotocol.io/specification/latest
- Servers must not accept tokens that were not issued to them. Bind state handles to the verified user. Use least-privilege scopes. https://modelcontextprotocol.io/specification/latest/basic/security_best_practices

## Context and memory

- Write system prompts at the right altitude. Start minimal. Add rules only for observed failures. https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- Keep identifiers and load data just in time. https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- Compact for recall first. Clear old tool results. https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- Subagents should return 1,000 to 2,000 token summaries. https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- Compaction can drop early instructions. Keep persistent rules in CLAUDE.md. https://code.claude.com/docs/en/agent-sdk/agent-loop
- Memory. Save only what cannot be re-read from the environment. Keep the injected index small. https://www.anthropic.com/research/components-of-agent-memory
- Memory. One writer per entity. A shared table lost 41 of 57 facts. Verify notes against transcripts. https://www.anthropic.com/research/components-of-agent-memory
- The memory tool is client-side. Validate paths against traversal. Cap size. Expire old files. https://platform.claude.com/docs/en/agents-and-tools/tool-use/memory-tool
- Keep the session log separate from the context window. Avoid irreversible trimming. https://www.anthropic.com/research/managed-agents
- RAG. Contextual embeddings, BM25 and reranking cut retrieval failures by 67%. Under about 200k tokens, skip RAG. https://www.anthropic.com/engineering/contextual-retrieval

## Evals and observability

- Draw 20 to 50 tasks from real failures. Grade the outcome, not the exact path. Start each trial clean. https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents
- Keep capability and regression suites apart. Use pass^k for customer-facing agents. https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents
- Calibrate LLM judges against humans. Give them an "Unknown" option. Read transcripts. https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents
- Human testing caught SEO-farm bias that automated evals missed. https://www.anthropic.com/engineering/multi-agent-research-system
- Resource limits moved one benchmark by 6 points. Treat infrastructure as an experiment variable. https://www.anthropic.com/research/infrastructure-noise
- Trace production runs. Resume from checkpoints. Use rainbow deploys. https://www.anthropic.com/engineering/multi-agent-research-system
- Trace-grade tool calls and decisions. https://developers.openai.com/api/docs/guides/agent-builder-safety
- OTel GenAI agent conventions (invoke_agent, execute_tool) are still "Development" status (unverified). https://opentelemetry.io/docs/specs/semconv/gen-ai/gen-ai-agent-spans

## Security and guardrails

- Lethal trifecta. Private data, untrusted content and external communication. Avoid combining them. https://simonwillison.net/2025/Jun/16/the-lethal-trifecta/
- Rule of Two. A session gets at most two of untrusted input, sensitive access, and state change or external comms. Otherwise require human approval. https://ai.meta.com/blog/practical-ai-agent-security/
- A guardrail that catches 95% is a failing grade. Prompts alone are not a defense. https://simonwillison.net/2025/Jun/16/the-lethal-trifecta/
- The best Anthropic browser result is 1.4% attack success against an adaptive attacker. Anthropic calls that meaningful risk. https://www.anthropic.com/research/prompt-injection-defenses
- Keep untrusted text out of developer messages. Use structured outputs between nodes. Require approval for MCP tool calls. https://developers.openai.com/api/docs/guides/agent-builder-safety
- Allowlist tools and use dontAsk mode. Deny rules run first. Use bypassPermissions only in isolated environments. https://code.claude.com/docs/en/agent-sdk/permissions
- Deny network egress by default. Keep credentials out of the sandbox. https://www.anthropic.com/research/how-we-contain-claude
- Users approved 93% of prompts. A model classifier missed 17% of real overeager actions. Use it inside a sandbox, not instead of one. https://www.anthropic.com/research/claude-code-auto-mode
- OWASP LLM Top 10 2025 includes prompt injection, excessive agency, system prompt leakage and unbounded consumption. https://genai.owasp.org/llm-top-10/

## Cost and latency

- Set max_turns and max_budget_usd. https://code.claude.com/docs/en/agent-sdk/agent-loop
- Use low effort for simple subagents. https://code.claude.com/docs/en/agent-sdk/agent-loop
- Prompt caching can cut cost up to 90% and latency 2x. https://www.anthropic.com/engineering/contextual-retrieval
- Route easy work to smaller models. https://www.anthropic.com/engineering/building-effective-agents
- Token use explained about 80% of performance variance on one benchmark. https://www.anthropic.com/engineering/multi-agent-research-system
- Parallel subagents and tool calls cut research time by up to 90%. https://www.anthropic.com/engineering/multi-agent-research-system
- Programmatic tool calling cut tokens 37% (vendor). https://www.anthropic.com/engineering/advanced-tool-use
- A full harness cost $200 versus $9 solo, with a much better result. Measure before adding roles. https://www.anthropic.com/research/harness-design-long-running-apps
- Provision sandboxes lazily. This cut p50 time-to-first-token by about 60%. https://www.anthropic.com/research/managed-agents

## Anti-patterns to flag in an audit

- Agent used where a workflow works. https://www.anthropic.com/engineering/building-effective-agents
- No turn, budget or stop limit. https://code.claude.com/docs/en/agent-sdk/agent-loop
- Thin endpoint-wrapper tools, overlapping tools, all schemas loaded upfront. https://www.anthropic.com/engineering/writing-tools-for-agents
- The trifecta in one agent with no human gate. https://ai.meta.com/blog/practical-ai-agent-security/
- bypassPermissions outside isolation, or secrets reachable from the sandbox. https://code.claude.com/docs/en/agent-sdk/permissions
- MCP token passthrough or wildcard scopes. https://modelcontextprotocol.io/specification/latest/basic/security_best_practices
- Untrusted text placed in system or developer prompts. https://developers.openai.com/api/docs/guides/agent-builder-safety
- No evals, path-exact graders, shared eval state. https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents
- The generator grades its own output. https://www.anthropic.com/research/harness-design-long-running-apps
- Parallel agents writing one shared memory store. https://www.anthropic.com/research/components-of-agent-memory
- Raw tool output dumped into context. https://www.anthropic.com/engineering/writing-tools-for-agents
- No tracing and no checkpoint resume. https://www.anthropic.com/engineering/multi-agent-research-system
- Old harness workarounds kept after model upgrades. https://www.anthropic.com/research/managed-agents

## Forward deployed engineer playbook

Vendor sources only. No primary research found. Treat as practice, not fact.

- Discovery. Run a structured interview. Exit with a falsifiable success definition. https://fde.academy/blog/forward-deployed-engineer-playbook
- Start from a business outcome. Pick frequent, painful, measurable problems. Map systems and permissions. https://www.atlassian.com/blog/guides-research/forward-deployed-engineering-playbook
- Scope the smallest deliverable. Agree what is out of scope. Tie each addition to the metric. https://fde.academy/blog/forward-deployed-engineer-playbook
- Pilot on the customer's real, messy data from day one. https://fde.academy/blog/forward-deployed-engineer-playbook
- Evals first. Build the harness before the build ends. Use graded criteria, not exact assertions. https://fde.academy/blog/forward-deployed-engineer-playbook
- Rollout. Deploy in the customer's environment. Set up observability before go-live. Watch closely for 2 to 3 weeks. https://fde.academy/blog/forward-deployed-engineer-playbook
- Build permissions and audit in from day one. Raise autonomy as trust grows. https://www.atlassian.com/blog/guides-research/forward-deployed-engineering-playbook
- Handover. Atlassian self-reports about 12 weeks to self-sufficient teams. https://www.atlassian.com/blog/guides-research/forward-deployed-engineering-playbook
- Feed custom-versus-product findings back to product teams. https://fde.academy/blog/forward-deployed-engineer-playbook
- Gap. No primary source on handover artifacts.

## Course topics

Source is the instructor's page, not Udemy. https://edwarddonner.com/2026/10/14/ai-fde-the-forward-deployed-engineer-agentic-ai-architect/

- Title. "AI FDE: The Forward Deployed Engineer and Agentic AI Architect". Three weeks, five days each.
- Week 1, AI Engineer. Frontier LLMs, structured outputs, prompt caching, coding agents, ADLC, open-source and token cost, harness engineering, Claude Agent SDK.
- Week 2, AI Architect. Langfuse evals and tracing, agentic RAG, MCP, memory, A2A, LangGraph durable state, interrupts and human-in-the-loop, swarms, self-improvement loops.
- Week 3, AI FDE. RICE prioritization, EU AI Act, security and guardrails, AgentCore gateway, policy and identity, enterprise context layer, production deployment, insurance-claims capstone.
- The page does not name discovery, scoping, pilots or handover as topics.
- Udemy listing, blocked to the research run. https://www.udemy.com/course/ai-fde-forward-deployed-engineer-agentic-ai-architect
