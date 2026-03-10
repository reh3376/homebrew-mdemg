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

## Command Reference

### Getting Started

| Command | Description |
|---------|-------------|
| `mdemg init` | Initialize a new MDEMG project (interactive wizard) |
| `mdemg init --defaults` | Non-interactive setup with sensible defaults |
| `mdemg init --quick` | Non-interactive setup + auto-start Neo4j and server |
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

### Configuration

| Command | Description |
|---------|-------------|
| `mdemg config show` | Display effective configuration with sources |
| `mdemg config validate` | Validate config file syntax and connectivity |
| `mdemg hooks install` | Install git post-commit hooks for auto-ingestion |
| `mdemg upgrade` | Self-update to the latest release |

## Status & Health Checks

```bash
# Full status overview
mdemg status

# HTTP health check
curl -s http://localhost:9999/healthz

# Readiness check (includes database)
curl -s http://localhost:9999/readyz

# Database-only status
mdemg db status
```

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
```

Priority (lowest → highest): defaults → config.yaml → .env → environment variables → CLI flags

View effective config: `mdemg config show`

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

## Man Page

After installation, the full manual is available:

```bash
man mdemg
man mdemg-init
man mdemg-db-start
```

## Links

- [Source Code](https://github.com/reh3376/mdemg)
- [Issues](https://github.com/reh3376/mdemg/issues)
