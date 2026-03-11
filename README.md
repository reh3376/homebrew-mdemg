# MDEMG — Multi-Dimensional Emergent Memory Graph

Persistent memory for AI agents. Observations accumulate, cluster into themes, and promote to emergent concepts through Hebbian learning — giving LLMs a long-term knowledge graph that grows and self-organizes.

## Prerequisites

- **macOS** (Apple Silicon or Intel)
- **[Homebrew](https://brew.sh)**
- **[Docker Desktop](https://www.docker.com/products/docker-desktop/)** (for Neo4j)
- **OpenAI API key** (recommended) — or [Ollama](https://ollama.com) for local-only operation

## Installation

```bash
brew tap reh3376/mdemg
brew install mdemg
mdemg version
```

## Quick Start

### Option A: One command

```bash
export OPENAI_API_KEY=sk-...
mdemg init --quick
```

Creates config, starts Neo4j, starts the server, applies migrations, and confirms readiness.

### Option B: Step by step

```bash
mdemg init                    # Interactive wizard — detects environment
mdemg db start                # Start Neo4j container
mdemg start --auto-migrate    # Start server with migrations
mdemg status                  # Verify everything is running
mdemg ingest --path .         # Ingest your codebase
```

## Commands

| Command | Description |
|---------|-------------|
| `mdemg init` | Interactive setup wizard (or `--defaults` / `--quick`) |
| `mdemg version` | Print version, commit, build date |
| `mdemg start` | Start server in background (daemon mode) |
| `mdemg stop` | Stop the running server |
| `mdemg restart` | Restart the server |
| `mdemg status` | Show server, database, and embedding status |
| `mdemg serve` | Run server in foreground (development) |
| `mdemg db start` | Start Neo4j container |
| `mdemg db stop` | Stop Neo4j container |
| `mdemg db status` | Show container and schema status |
| `mdemg db migrate` | Apply pending schema migrations |
| `mdemg db shell` | Open interactive cypher-shell |
| `mdemg db backup` | Trigger, list, or configure backups |
| `mdemg ingest` | Ingest a codebase into the knowledge graph |
| `mdemg consolidate` | Run hidden layer clustering and consolidation |
| `mdemg watch` | Watch a directory and auto-ingest on changes |
| `mdemg extract-symbols` | Extract code symbols via tree-sitter |
| `mdemg embeddings check` | Verify embedding provider connectivity |
| `mdemg config show` | Display effective configuration with sources |
| `mdemg config validate` | Validate config syntax and probe connectivity |
| `mdemg hooks install` | Install git post-commit hooks for auto-ingestion |
| `mdemg sidecar` | Manage sidecar services (12 subcommands) |
| `mdemg upgrade` | Self-update to the latest release |
| `mdemg decay` | Apply temporal decay to learning edges |
| `mdemg prune` | Prune weak edges, tombstone orphans |
| `mdemg mcp` | Run MCP server for IDE integration |
| `mdemg space` | Manage memory spaces (list, export, import) |
| `mdemg plugin` | Manage plugins |
| `mdemg demo` | Run interactive demo |

For complete flag details, defaults, and examples see the [CLI Reference](docs/cli-reference.md).

## Documentation

| Guide | What it covers |
|-------|---------------|
| [CLI Reference](docs/cli-reference.md) | All commands, flags, defaults, examples, environment variables |
| [API Reference](docs/api-reference.md) | Every HTTP endpoint with request/response shapes and curl examples |
| [CMS & RSIC Guide](docs/cms-rsic-guide.md) | Conversation memory, observation types, surprise scoring, self-improvement cycles |
| [Ingestion Guide](docs/ingestion-guide.md) | All 8 ingestion methods — codebase, scraper, Linear, webhooks, file watcher, API |

## Configuration

Priority chain (lowest to highest):

```
defaults → .mdemg/config.yaml → keychain → .env → environment variables → CLI flags
```

View effective config with source annotations:

```bash
mdemg config show
```

Validate syntax and probe connectivity:

```bash
mdemg config validate
```

Config file: `.mdemg/config.yaml` (created by `mdemg init`). Secrets go in `.env` (gitignored) or the system keychain via `mdemg config set-secret`.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Docker not running | Start Docker Desktop, then retry |
| Neo4j port conflict | Stop other Neo4j instances, or `mdemg db start --port 7688` |
| Missing OpenAI key | `echo 'OPENAI_API_KEY=sk-...' >> .env && mdemg restart` |
| Neo4j won't start | `docker logs mdemg-neo4j-$(basename $(pwd))` |
| Server won't start | `cat .mdemg/logs/mdemg.log` |
| Embedding check fails | `mdemg embeddings check` — verify API key and model in config |

## Upgrading

```bash
brew update && brew upgrade mdemg
mdemg start --auto-migrate   # apply any new migrations
```

## Uninstall

```bash
mdemg stop && mdemg db stop --remove
docker volume rm $(docker volume ls -q --filter name=mdemg)
brew uninstall mdemg && brew untap reh3376/mdemg
```

## Man Pages

```bash
man mdemg
man mdemg-init
man mdemg-ingest
```

## Links

- [Source Code](https://github.com/reh3376/mdemg)
- [Issues](https://github.com/reh3376/mdemg/issues)
