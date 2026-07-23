# Claude Code Configuration

Personal Claude Code CLI configuration repository - a dotfiles-style setup for managing preferences, custom agents, skills, and project-specific settings.

## Overview

This repository contains my personalized Claude Code workspace configuration, tracking everything from custom agents and skills to security settings and personal instructions. It's version-controlled to enable reproducible setups across machines and to maintain a history of configuration changes.

### Key Features

- **Custom Agents**: Specialized agents for documentation lookup and other tasks
- **Custom Skills**: Reusable workflows for debugging, browser automation, and metadata parsing
- **Security-First Defaults**: Plan mode enabled, sandbox mode active, environment file protection
- **Project Tracking**: Configuration for 18+ active projects
- **Plugin Ecosystem**: Integrated with ralph-loop, datadog, context7, playwright, and more
- **Personal Instructions**: Mandarin learning integration and documentation reference requirements

## Directory Structure

### Version-Controlled Directories

| Directory | Purpose |
|-----------|---------|
| `/agents/` | Custom agent definitions (e.g., DocRabbit) |
| `/skills/` | Custom skill implementations |
| `/plans/` | Saved implementation plans from previous sessions |
| `CLAUDE.md` | Personal instructions applied to all projects |
| `settings.json` | Main configuration file |
| `.gitignore` | Allowlist-based ignore rules |

### Runtime Directories (Git-Ignored)

| Directory | Purpose |
|-----------|---------|
| `/projects/` | Tracked project configurations and metadata |
| `/session-env/` | Session-specific environment snapshots |
| `/file-history/` | Version history for edited files |
| `/cache/` | Cached data including changelog |
| `/backups/` | Automatic configuration backups |
| `/plugins/` | Installed plugin data |
| `/telemetry/` | Usage telemetry and analytics |
| `history.jsonl` | Command and interaction history |

## Custom Agents

### DocRabbit

Documentation lookup specialist that proactively fetches up-to-date documentation for libraries, frameworks, and technologies.

**Features:**
- Parallel documentation fetching for multiple technologies
- Context7 MCP integration as primary source
- Intelligent fallback to web search for uncovered libraries
- Prioritizes machine-readable formats (llms.txt, markdown)

**When to Use:**
- Working with third-party libraries or packages
- Need API reference or usage examples
- Checking current best practices for a framework

**Example:**
```
Use DocRabbit agent to fetch documentation for React and Next.js
```

**Location:** `/agents/DocRabbit.md`

## Custom Skills

### systematic-debugging

Comprehensive 4-phase debugging methodology for investigating and resolving bugs.

**Phases:**
1. Root cause investigation
2. Hypothesis formation
3. Validation testing
4. Fix implementation

**When to Use:**
- Encountering any bug, test failure, or unexpected behavior
- Before proposing fixes (to ensure proper diagnosis)

**Invocation:**
```
/systematic-debugging
```

**Location:** `/skills/systematic-debugging/`

### agent-browser

Browser automation CLI wrapper for AI agents.

**Capabilities:**
- Navigate web pages
- Fill forms and click elements
- Capture screenshots
- Extract data from pages
- Test web applications

**When to Use:**
- Automating browser interactions
- Web scraping or data extraction
- Testing web applications in real browsers

**Invocation:**
```
/agent-browser
```

**Location:** `/skills/agent-browser/`

### parse-aigc-metadata

Simple metadata extraction utility using strings and grep.

**When to Use:**
- Extracting metadata from files
- Pattern matching across file collections

**Invocation:**
```
/parse-aigc-metadata
```

**Location:** `/skills/parse-aigc-metadata/`

## Configuration

### settings.json

**Key Configuration Choices:**

- **Default Permission Mode:** `plan` - Claude creates execution plans before making changes
- **Sandbox:** Enabled with auto-allow for sandboxed bash commands
- **Model:** `claude-sonnet-4-5` (primary model)
- **Effort Level:** `high` - thorough analysis and implementation
- **Notifications:** Enabled for background task completion

**Security Settings:**

```json
{
  "permissions": {
    "defaultMode": "plan",
    "deny": ["Bash(**/.env)", "Read(**/.env)", "Write(**/.env)"]
  },
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true
  }
}
```

**Bash Command Permissions:**

Allowed commands include safe operations like `npm test`, `git status`, `ls`, etc.

Denied commands include destructive operations like `rm -rf`, `git push --force`, `sudo`, etc.

**System Prompt:**

> "You are a senior engineer. Always explain the tradeoff before making a significant change. Prefer small, incremental edits over large rewrites. Flag anything that could affect existing tests."

### CLAUDE.md

Personal instructions applied globally to all projects:

1. **Mandarin Learning:** After every completed task, teach a new Mandarin word with pinyin, hanzi, pronunciation, and example sentence
2. **Documentation Requirement:** Must reference up-to-date documentation for any third-party libraries using the DocRabbit agent

## Installed Plugins

| Plugin | Scope | Description |
|--------|-------|-------------|
| ralph-loop | User | Recurring task execution and monitoring |
| datadog | Project | Monitoring and observability integration |
| context7 | Project | Documentation context provider (MCP) |
| playwright | Project | Browser automation testing |
| frontend-design | Project | UI/UX design assistance |
| independent-reviewer | Project | Code review automation |

## Installation & Setup

### Prerequisites

- Claude Code CLI installed (`npm install -g @anthropic-ai/claude-code`)
- Git configured with your credentials
- Node.js/npm or Yarn (for project dependencies)

### Using This Configuration

This repository represents the `~/.claude` directory. To use this configuration on a new machine:

1. **Clone the repository:**
   ```bash
   git clone <repository-url> ~/.claude-config
   ```

2. **Backup existing configuration (if any):**
   ```bash
   mv ~/.claude ~/.claude.backup
   ```

3. **Create symlink or copy:**
   ```bash
   # Option A: Symlink (changes sync automatically)
   ln -s ~/.claude-config ~/.claude
   
   # Option B: Copy (manual sync required)
   cp -r ~/.claude-config ~/.claude
   ```

4. **Verify setup:**
   ```bash
   claude --version
   ```

### First-Time Setup Steps

1. Authenticate with Claude Code
2. Review and adjust `settings.json` for your preferences
3. Install desired plugins using `/plugins` command
4. Customize `CLAUDE.md` with your personal instructions

## Usage Examples

### Using DocRabbit for Documentation

When working with a new library:

```
I need to implement authentication using Supabase. Use DocRabbit to fetch the latest docs.
```

Claude will spawn the DocRabbit agent to fetch current documentation from Context7 MCP or official sources.

### Invoking Systematic Debugging

When encountering a bug:

```
/systematic-debugging

The login form is submitting but not redirecting users. The console shows no errors.
```

The skill will guide through root cause analysis, hypothesis formation, validation, and fix implementation.

### Running Browser Automation

For web testing or automation:

```
/agent-browser

Navigate to https://example.com, fill in the contact form with test data, and capture a screenshot
```

## Project Tracking

This configuration tracks 18+ active projects, including:

- **WPP Unite Monorepo** - Primary focus area with multiple services (intbriefbe, renderer, projectman)
- **Personal Projects** - CV, dotfiles, ML experiments
- **Hobbitz** - Clojure-based project

Each project maintains its own `.claude/` subdirectory with project-specific settings and metadata.

## Maintenance

### Adding New Skills

1. Create skill directory: `/skills/<skill-name>/`
2. Add skill metadata and instructions
3. Test with `/skill-name` invocation
4. Commit changes to version control

### Adding New Agents

1. Create agent file: `/agents/<AgentName>.md`
2. Define frontmatter (name, description, tools, model)
3. Document agent workflow and output format
4. Test agent invocation
5. Commit to repository

### Updating Configuration

1. Edit `settings.json` for preference changes
2. Test changes in a new Claude Code session
3. Commit with descriptive message
4. Push to remote for backup

### Backup Strategy

- Configuration is version-controlled via Git
- Automatic backups in `/backups/` directory
- Runtime directories excluded via `.gitignore`
- Push regularly to remote repository for redundancy

## Security Considerations

- Environment files (`.env`) are explicitly denied from read/write operations
- Plan mode prevents accidental destructive changes
- Sandbox mode isolates bash command execution
- Destructive bash commands are blocked (e.g., `rm -rf`, `sudo`)
- Git force-push is denied to prevent accidental history rewrites

## Contributing

This is a personal configuration repository, but if you're interested in specific agents or skills:

1. Fork the repository
2. Extract the agent/skill you want
3. Adapt to your own setup
4. Consider sharing improvements back

## Resources

- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [Claude API Reference](https://docs.anthropic.com/claude/reference)
- [MCP Protocol](https://modelcontextprotocol.io/)

## License

Personal configuration - use at your own discretion. No warranty provided.

---

**Last Updated:** 2026-07-23
**Claude Code Version:** 2.1.218+
**Primary Model:** claude-sonnet-4-5
