# MDEMG — Multi-Dimensional Emergent Memory Graph

A persistent memory system for AI agents. MDEMG gives LLMs emergent long-term memory where concepts and relationships arise automatically from accumulated observations through Hebbian learning.

## Prerequisites

- **macOS** (Apple Silicon or Intel)
- **[Homebrew](https://brew.sh)** package manager
- **[Docker Desktop](https://www.docker.com/products/docker-desktop/)** (for Neo4j database)
- **OpenAI API key** (recommended) — or Ollama for local-only operation

## Installation

```bash
brew tap reh3376/mdemg
brew install mdemg
```

Verify:

```bash
mdemg version
```

## Quick Start

### Option A: One-command setup

```bash
export OPENAI_API_KEY=sk-...
mdemg init --quick
```

This creates config, starts Neo4j, starts the server, and applies database migrations — all in one step.

### Option B: Step-by-step

```bash
# 1. Initialize project config
mdemg init

# 2. Start Neo4j database
mdemg db start

# 3. Start the MDEMG server (applies migrations)
mdemg start --auto-migrate

# 4. Check everything is running
mdemg status

# 5. Ingest your codebase
mdemg ingest --path .
```

---

## Command Reference

### Getting Started

| Command | Description |
|---------|-------------|
| `mdemg init` | Interactive wizard — detects environment, creates config |
| `mdemg init --defaults` | Non-interactive with sensible defaults |
| `mdemg init --quick` | Non-interactive + auto-start Neo4j and server |
| `mdemg version` | Print version, commit, and build date |

### Server Lifecycle

| Command | Description |
|---------|-------------|
| `mdemg start` | Start the server in the background (daemon mode) |
| `mdemg start --auto-migrate` | Start with automatic database migrations |
| `mdemg stop` | Stop the running server |
| `mdemg restart` | Stop and restart the server |
| `mdemg status` | Show server, database, and embedding status |
| `mdemg serve` | Run server in foreground (for development) |

### Database Management

| Command | Description |
|---------|-------------|
| `mdemg db start` | Start a local Neo4j container |
| `mdemg db stop` | Stop the Neo4j container |
| `mdemg db status` | Show container and schema status |
| `mdemg db migrate` | Apply pending schema migrations |
| `mdemg db shell` | Open interactive cypher-shell |

### Memory & Ingestion

| Command | Description |
|---------|-------------|
| `mdemg ingest --path .` | Ingest a codebase into the knowledge graph |
| `mdemg consolidate` | Run graph consolidation (hidden layer, clustering) |
| `mdemg embeddings check` | Verify embedding provider connectivity |
| `mdemg watch --space-id myspace --path .` | Watch a directory for changes and auto-ingest |
| `mdemg extract-symbols --path .` | Extract code symbols using tree-sitter |

### Configuration

| Command | Description |
|---------|-------------|
| `mdemg config show` | Display effective configuration with sources |
| `mdemg config validate` | Validate config file syntax and connectivity |
| `mdemg hooks install` | Install git post-commit hooks for auto-ingestion |
| `mdemg upgrade` | Self-update to the latest release |

### Advanced

| Command | Description |
|---------|-------------|
| `mdemg decay` | Apply temporal decay to learning edges |
| `mdemg prune` | Prune weak edges, tombstone orphans, merge redundant nodes |
| `mdemg mcp` | Run MCP server for IDE integration (Cursor, VS Code) |
| `mdemg space list` | List all memory spaces |
| `mdemg space export --space-id X` | Export a space to JSON |
| `mdemg space import --file X.json` | Import a space from JSON |

---

## Ingestion Methods

MDEMG supports multiple ways to get knowledge into the graph.

### Codebase Ingestion

Ingest an entire codebase with symbol extraction, language detection, and optional LLM summaries.

```bash
# Full codebase ingest
mdemg ingest --path /path/to/repo --space-id my-project

# With symbol extraction and LLM summaries
mdemg ingest --path . --extract-symbols --llm-summary

# Incremental (only changed files since last ingest)
mdemg ingest --path . --incremental

# Language filters
mdemg ingest --path . --include-go --include-py --include-ts

# Dry run (show what would be ingested)
mdemg ingest --path . --dry-run
```

**Key flags:**
- `--batch` — Batch size (default: 100)
- `--workers` — Parallel workers (default: 4)
- `--extract-symbols` — Extract functions, classes, types via tree-sitter
- `--llm-summary` — Generate LLM summaries for each file
- `--incremental` — Only process files changed since last ingest
- `--consolidate` — Run consolidation after ingestion
- `--preset` — Exclusion preset (`default`, `ml_cuda`, `web_monorepo`)

### Web Scraper Ingestion

Scrape documentation sites and web content into the knowledge graph.

```bash
# Create a scrape job via API
curl -X POST http://localhost:9999/v1/scraper/jobs \
  -H "Content-Type: application/json" \
  -d '{
    "urls": ["https://docs.example.com/guide"],
    "target_space_id": "docs-space",
    "extraction_profile": "documentation",
    "max_depth": 3,
    "follow_links": true
  }'

# Check job status
curl http://localhost:9999/v1/scraper/jobs/{job_id}

# Review and approve scraped content
curl -X POST http://localhost:9999/v1/scraper/jobs/{job_id}/review \
  -H "Content-Type: application/json" \
  -d '{"decisions": [{"url": "https://...", "action": "approve"}]}'
```

**Extraction profiles:** `documentation`, `forum`, `blog`, `news`, `generic`

### Linear Integration

Ingest Linear issues and projects, with real-time webhook updates.

```bash
# List issues
curl http://localhost:9999/v1/linear/issues?team=TEAM_ID

# Create issue
curl -X POST http://localhost:9999/v1/linear/issues \
  -H "Content-Type: application/json" \
  -d '{"title": "Bug fix", "team_id": "TEAM_ID", "description": "..."}'
```

**Webhook setup:** Configure `LINEAR_WEBHOOK_SECRET` and `LINEAR_WEBHOOK_SPACE_ID` in `.env`, then point Linear webhooks to `http://your-host:9999/v1/webhooks/linear`.

### Generic Webhooks (GitHub, GitLab, Bitbucket)

Auto-ingest push events, PRs, and issues from git hosts.

```bash
# Configure in .env
WEBHOOK_CONFIGS="github:my-secret:github-space,gitlab:other-secret:gitlab-space"
```

Point your git host webhook to `http://your-host:9999/v1/webhooks/{source}` where source is `github`, `gitlab`, or `bitbucket`.

### File Watcher

Monitor a directory for real-time changes and auto-ingest.

```bash
# CLI watcher
mdemg watch --space-id my-project --path /path/to/repo

# API watcher
curl -X POST http://localhost:9999/v1/filewatcher/start \
  -H "Content-Type: application/json" \
  -d '{"space_id": "my-project", "path": "/path/to/repo"}'
```

### Direct Observation Ingest

Ingest individual observations programmatically.

```bash
# Single observation
curl -X POST http://localhost:9999/v1/memory/ingest \
  -H "Content-Type: application/json" \
  -d '{
    "space_id": "my-space",
    "content": "The auth module uses JWT tokens with RS256 signing",
    "source": "manual",
    "tags": ["auth", "security"]
  }'

# Batch ingest
curl -X POST http://localhost:9999/v1/memory/ingest/batch \
  -H "Content-Type: application/json" \
  -d '{
    "space_id": "my-space",
    "observations": [
      {"content": "...", "source": "...", "tags": ["..."]},
      {"content": "...", "source": "...", "tags": ["..."]}
    ]
  }'
```

---

## Conversation Memory System (CMS)

CMS provides persistent conversation memory for AI agents — the equivalent of an internal dialogue. Observations are captured, clustered into themes, and promoted to emergent concepts through Hebbian learning.

### Observe (Capture Knowledge)

```bash
curl -X POST http://localhost:9999/v1/conversation/observe \
  -H "Content-Type: application/json" \
  -d '{
    "space_id": "mdemg-dev",
    "session_id": "session-001",
    "content": "User prefers snake_case for Python, camelCase for TypeScript",
    "obs_type": "preference"
  }'
```

**Observation types:** `decision`, `learning`, `preference`, `error`, `task`, `correction`

Each observation gets a **surprise score** (0–1) based on:
- Correction weight (40%) — user explicitly corrected the agent
- Term novelty (25%) — domain-specific terminology detected
- Embedding novelty (25%) — semantic distance from existing knowledge
- Contradiction (10%) — conflicts with known facts

### Correct (Record Mistakes)

```bash
curl -X POST http://localhost:9999/v1/conversation/correct \
  -H "Content-Type: application/json" \
  -d '{
    "space_id": "mdemg-dev",
    "session_id": "session-001",
    "incorrect": "The API uses REST with JSON",
    "correct": "The API uses gRPC with protobuf"
  }'
```

### Resume (Restore Context)

Called at session start to restore memory after context window compaction.

```bash
curl -X POST http://localhost:9999/v1/conversation/resume \
  -H "Content-Type: application/json" \
  -d '{
    "space_id": "mdemg-dev",
    "session_id": "session-001",
    "max_observations": 10
  }'
```

Returns recent observations, conversation themes, emergent concepts, and a generated summary.

### Recall (Semantic Query)

```bash
curl -X POST http://localhost:9999/v1/conversation/recall \
  -H "Content-Type: application/json" \
  -d '{
    "space_id": "mdemg-dev",
    "query": "What are the user preferences for code style?",
    "top_k": 5
  }'
```

### Consolidate (Build Hierarchy)

Clusters observations into themes (Layer 1) and concepts (Layer 2+).

```bash
curl -X POST http://localhost:9999/v1/conversation/consolidate \
  -H "Content-Type: application/json" \
  -d '{"space_id": "mdemg-dev"}'
```

### Graduate (Lifecycle Management)

Process observation graduations (volatile → permanent) and apply decay.

```bash
curl -X POST http://localhost:9999/v1/conversation/graduate \
  -H "Content-Type: application/json" \
  -d '{"space_id": "mdemg-dev"}'
```

### Session Health

```bash
curl "http://localhost:9999/v1/conversation/session/health?session_id=session-001"
```

### Constraints

Architectural constraints are auto-detected from observations and enforced as guardrails.

```bash
# List constraints
curl "http://localhost:9999/v1/constraints?space_id=mdemg-dev"

# Validate against guardrails
curl -X POST http://localhost:9999/v1/memory/guardrail/validate \
  -H "Content-Type: application/json" \
  -d '{"space_id": "mdemg-dev", "content": "proposed change..."}'
```

---

## RSIC (Recursive Self-Improvement Cycle)

RSIC automatically monitors and optimizes the memory graph through assess → reflect → plan → execute → validate cycles.

### Assess System Health

```bash
curl -X POST http://localhost:9999/v1/self-improve/assess \
  -H "Content-Type: application/json" \
  -d '{"space_id": "mdemg-dev", "tier": "meso"}'
```

Returns: `overall_health`, `retrieval_quality`, `memory_health`, `edge_health`, `learning_phase`, `orphan_ratio`, `correction_rate`, and more.

### Run a Full Cycle

```bash
# Standard cycle
curl -X POST http://localhost:9999/v1/self-improve/cycle \
  -H "Content-Type: application/json" \
  -d '{"space_id": "mdemg-dev", "tier": "meso"}'

# Dry run (preview actions without executing)
curl -X POST http://localhost:9999/v1/self-improve/cycle \
  -H "Content-Type: application/json" \
  -d '{"space_id": "mdemg-dev", "tier": "meso", "dry_run": true}'
```

**Cycle tiers:**
- `micro` — per-request opportunistic (fast, lightweight)
- `meso` — periodic (hours/sessions, moderate)
- `macro` — cron-scheduled deep maintenance (comprehensive)

### RSIC Health Dashboard

```bash
curl http://localhost:9999/v1/self-improve/health
```

Returns: active tasks, watchdog state (decay score, escalation level), orchestration status, safety enforcement bounds, and persistence status.

### Cycle History

```bash
# Recent cycles
curl "http://localhost:9999/v1/self-improve/history?limit=10"

# Filter by trigger source
curl "http://localhost:9999/v1/self-improve/history?trigger_source=watchdog_force"
```

### Calibration

```bash
curl http://localhost:9999/v1/self-improve/calibration
```

Returns per-action confidence scores learned from previous cycles.

### Rollback

If a cycle causes issues, roll back to a pre-cycle snapshot.

```bash
# List available snapshots
curl http://localhost:9999/v1/self-improve/rollback

# Execute rollback
curl -X POST http://localhost:9999/v1/self-improve/rollback \
  -H "Content-Type: application/json" \
  -d '{"snapshot_id": "snap-abc123"}'
```

---

## Memory Retrieval & Consultation

### Semantic Retrieval

```bash
curl -X POST http://localhost:9999/v1/memory/retrieve \
  -H "Content-Type: application/json" \
  -d '{
    "space_id": "my-project",
    "query": "How does the authentication module work?",
    "top_k": 10
  }'
```

Uses hybrid vector + BM25 retrieval, graph-based activation spreading, and optional LLM re-ranking.

### SME Consulting

```bash
curl -X POST http://localhost:9999/v1/memory/consult \
  -H "Content-Type: application/json" \
  -d '{
    "space_id": "my-project",
    "question": "What are the security implications of this change?"
  }'
```

### Skills Registry

```bash
# List skills
curl "http://localhost:9999/v1/skills?space_id=mdemg-dev"

# Recall a skill
curl -X POST http://localhost:9999/v1/skills/commit-workflow/recall \
  -H "Content-Type: application/json" \
  -d '{"space_id": "mdemg-dev"}'

# Register a new skill
curl -X POST http://localhost:9999/v1/skills/my-skill/register \
  -H "Content-Type: application/json" \
  -d '{
    "space_id": "mdemg-dev",
    "sections": [{"title": "Steps", "content": "1. Do X\n2. Do Y"}]
  }'
```

### Learning Edge Management

```bash
# Freeze learning (for stable scoring during benchmarks)
curl -X POST http://localhost:9999/v1/learning/freeze \
  -H "Content-Type: application/json" \
  -d '{"space_id": "mdemg-dev", "reason": "benchmark run"}'

# Unfreeze
curl -X POST http://localhost:9999/v1/learning/unfreeze \
  -H "Content-Type: application/json" \
  -d '{"space_id": "mdemg-dev"}'

# Check freeze status
curl "http://localhost:9999/v1/learning/freeze/status?space_id=mdemg-dev"
```

### Memory Distribution & Stats

```bash
# Distribution (learning phase, edge count, alerts)
curl "http://localhost:9999/v1/memory/distribution?space_id=mdemg-dev"

# Full stats
curl "http://localhost:9999/v1/memory/stats?space_id=mdemg-dev"
```

---

## Status & Health Checks

```bash
# Full status overview
mdemg status

# HTTP health check
curl http://localhost:9999/healthz

# Readiness check (includes database connectivity)
curl http://localhost:9999/readyz

# Embedding provider health
curl http://localhost:9999/v1/embedding/health

# Database-only status
mdemg db status
```

---

## Configuration

Config file: `.mdemg/config.yaml` (created by `mdemg init`)

```yaml
neo4j:
  uri: bolt://localhost:7687
  user: neo4j
  bolt_port: 7687
  http_port: 7474
server:
  port: 9999
llm:
  provider: openai
  model: gpt-5-nano
embedding:
  provider: openai
  model: gpt-5-mini
schema:
  version: 17
```

Secrets go in `.env` (gitignored):

```bash
NEO4J_PASS=your-password
OPENAI_API_KEY=sk-...
LINEAR_WEBHOOK_SECRET=your-secret
LINEAR_WEBHOOK_SPACE_ID=linear-space
WEBHOOK_CONFIGS=github:secret:gh-space
```

Priority (lowest to highest): defaults → config.yaml → .env → environment variables → CLI flags

View effective config: `mdemg config show`

---

## Troubleshooting

### Docker not running

```
Error: docker is not installed or not in PATH
```

Start Docker Desktop, then retry.

### Port conflict (Neo4j)

```
Error: find available bolt port: all ports in range 7687-7787 are in use
```

Another Neo4j instance is running. Stop it or use `mdemg db start --port 7688`.

### Missing OpenAI API key

If embedding/LLM features aren't working, ensure your key is set:

```bash
echo 'OPENAI_API_KEY=sk-...' >> .env
mdemg restart
```

### Neo4j won't start

Check Docker logs:

```bash
docker logs mdemg-neo4j-$(basename $(pwd))
```

### Server won't start

Check the log file:

```bash
cat .mdemg/logs/mdemg.log
```

### Embedding health check fails

```bash
mdemg embeddings check
curl http://localhost:9999/v1/embedding/health
```

Verify your API key and model name in `mdemg config show`.

---

## Upgrading

```bash
brew update
brew upgrade mdemg
```

After upgrading, apply any new database migrations:

```bash
mdemg start --auto-migrate
# or if already running:
mdemg restart --auto-migrate
```

---

## Uninstall

```bash
# Stop services
mdemg stop
mdemg db stop --remove

# Remove Docker volume (WARNING: deletes all data)
docker volume rm $(docker volume ls -q --filter name=mdemg)

# Uninstall
brew uninstall mdemg
brew untap reh3376/mdemg
```

---

## Man Page

After installation, the full manual is available:

```bash
man mdemg
man mdemg-init
man mdemg-db-start
man mdemg-ingest
```

---

## Links

- [Source Code](https://github.com/reh3376/mdemg)
- [Issues](https://github.com/reh3376/mdemg/issues)
