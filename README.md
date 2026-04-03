# MDEMG — Multi-Dimensional Emergent Memory Graph

Persistent, self-organizing memory for AI agents. Observations accumulate, cluster into themes, and promote to emergent concepts through Hebbian learning — giving LLMs a long-term knowledge graph that grows, self-improves, and develops understanding over time.

MDEMG is not a vector database or a RAG pipeline. It is a **cognitive substrate** — a 5-layer neural memory hierarchy that mirrors how biological memory consolidates short-term experience into long-term knowledge.

---

## How It Works

### 5-Layer Memory Hierarchy

| Layer | Name | What it stores |
|-------|------|---------------|
| L0 | Observations | Raw inputs — code files, conversation notes, ingested documents, each with embeddings and summaries |
| L1 | Themes | Clustered groups of related observations, formed via graph convolution |
| L2 | Concepts | Higher-order abstractions that emerge from theme co-occurrence |
| L3–L4 | Meta-Concepts | Cross-domain patterns, analogies, and bridges between concept clusters |
| L5 | Principles | Emergent rules and architectural patterns with dynamic relationship typing (`ANALOGOUS_TO`, `CONTRASTS_WITH`, `BRIDGES`) |

Observations enter at L0. The consolidation pipeline automatically clusters, promotes, and interconnects them upward. No manual taxonomy required — structure emerges from the data.

### Hebbian Learning

"Neurons that fire together wire together." When concepts are retrieved together, their connecting edges strengthen. Over time, the graph encodes which ideas are genuinely related based on usage patterns, not just embedding similarity.

### Surprise Scoring

Every observation receives a novelty score (0.0–1.0). Redundant information decays; genuinely novel inputs persist longer and trigger faster consolidation. This prevents the graph from drowning in repetitive data.

### RSIC Self-Improvement

The Recursive Self-Improvement Cycle continuously optimizes the memory system itself:

- **Assess** — 9 health dimensions (retrieval quality, edge consistency, orphan ratio, embedding coverage, ...)
- **Reflect** — Pattern detection across recent performance
- **Act** — Safety-bounded corrective actions (edge refresh, re-embedding, consolidation triggers)

Three orchestration tiers: micro (per-request), meso (per-session), macro (scheduled).

### Jiminy Inner Voice

An internal guidance system that surfaces constraints, suggestions, and warnings during retrieval. Jiminy tracks whether its guidance is followed, ignored, or contradicted — and adjusts confidence accordingly.

---

## Key Features

**Memory & Retrieval**
- Hybrid retrieval: vector similarity + BM25 keyword search + graph traversal (configurable hop depth)
- Conversation memory with session resume, observation tracking, and temporal queries
- Multi-space isolation — separate knowledge graphs per project, exportable and portable

**Ingestion**
- 8 ingestion methods: codebase scan, file watcher, git hooks, Claude Code memory files, Linear tickets, web scraper, webhooks, direct API
- Tree-sitter symbol extraction for 15+ languages
- Incremental ingest with content hashing (only changed files re-processed)

**Consolidation**
- Automatic clustering via graph convolution at each layer boundary
- Temporal decay on learning edges — stale connections weaken naturally
- Pruning of weak edges and tombstoning of orphan nodes

**Integrations**
- **MCP server** for IDE integration (VS Code, Cursor, Claude Code)
- **Claude Code synergy** — token optimization, buffer health monitoring, memory file bridging
- **Grafana dashboards** for Jiminy, RSIC, Neo4j, and training metrics
- **Plugin system** with manifest-based scaffolding (INGESTION, REASONING, APE types)

**Operations**
- Docker Compose deployment (5 services: Neo4j, TimescaleDB, MDEMG server, neural sidecar, Grafana)
- Browser dashboard at `/ui/` with 9 tabs (Status, Memory, Learning, Config, Logs, RSIC, Plugins, Features, Backups)
- OS-level service management (`mdemg service install` for launchd/systemd)
- Self-update with SHA-256 verification (`mdemg upgrade`, `mdemg upgrade --edge`)
- Training data collection via TimescaleDB for fine-tuning pipelines
- Multi-instance support — run separate MDEMG stacks per project on one machine

### Training Pipeline

MDEMG includes a complete LoRA fine-tuning pipeline for personalizing local LLMs:

1. **Collect** — LLM interactions recorded to TimescaleDB during normal use
2. **Export** — `mdemg data export` or automated daily via `mdemg data export-auto`
3. **Curate** — quality filter, format converter, dataset versioner (privacy-safe, temporal splits)
4. **Train** — LoRA fine-tuning via MLX on Apple Silicon (`train_ft.py`)
5. **Evaluate** — per-task scoring against quality metrics (`evaluate_ft.py`)
6. **Gate** — regression gate prevents deploying worse adapters (`regression_gate.py`)
7. **Deploy** — fuse adapter + quantize for production inference (`quantize_deploy.py`)

### Collection Campaign

To maximize training data quality, enable task-specific data collection:

```bash
mdemg init  # Answer "yes" to "Enable training data collection tasks?"
# Or manually in .env:
QUERY_CLASSIFY_ENABLED=true
INTENT_ENABLED=true
```

Run `mdemg data check --pre-campaign` to verify your instance is configured correctly.

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│                   CLI (mdemg)                   │
├─────────────────────────────────────────────────┤
│              HTTP API (40+ endpoints)           │
├──────────┬──────────┬──────────┬────────────────┤
│ Retrieval│ Hidden   │  RSIC    │    Jiminy      │
│ Pipeline │ Layers   │  Engine  │  Inner Voice   │
├──────────┴──────────┴──────────┴────────────────┤
│          Neo4j (knowledge graph)                │
│          TimescaleDB (training data)            │
│          Grafana (observability)                │
│          Neural Sidecar (background tasks)      │
└─────────────────────────────────────────────────┘
```

---

## Supported Platforms

| Platform | Architecture | Install method |
|----------|-------------|----------------|
| macOS 12+ | Apple Silicon (arm64) | `brew install mdemg` |
| Linux | x86_64, arm64 | [Install script](https://github.com/reh3376/mdemg/blob/main/scripts/install.sh) |
| Windows | WSL2 | [Install script](https://github.com/reh3376/mdemg/blob/main/scripts/install.sh) (inside WSL2) |

All platforms require Docker Desktop (or Docker Engine on Linux) for the service stack.

---

## Quick Start

```bash
# macOS
brew tap reh3376/mdemg && brew install mdemg

# Linux / WSL2
curl -fsSL https://raw.githubusercontent.com/reh3376/mdemg/main/scripts/install.sh | bash
```

```bash
cd ~/your-project
mdemg init           # Interactive wizard — generates .env, starts 5 Docker services
mdemg ingest --path . # Ingest codebase into the knowledge graph
open http://localhost:9999/ui/  # Browser dashboard
```

For detailed installation, prerequisites, and verification steps, see the [Beta Testing Guide](mdemg_beta_testing.md).

---

## CLI Overview

MDEMG ships a single binary with command groups for every subsystem:

| Group | Commands | Purpose |
|-------|----------|---------|
| Core | `init`, `status`, `version`, `upgrade`, `teardown` | Setup, health, updates |
| Server | `start`, `stop`, `restart`, `serve`, `service` | Server lifecycle |
| Memory | `ingest`, `ingest-claude-md`, `consolidate`, `watch`, `prune`, `decay` | Data pipeline |
| Database | `db`, `tsdb` | Neo4j and TimescaleDB management |
| Config | `config show`, `config validate`, `config set-secret` | Configuration and secrets |
| Spaces | `space list`, `space export`, `space import`, `space copy` | Multi-space management |
| Hooks | `hooks install`, `hooks uninstall`, `hooks list` | Git integration |
| Sidecar | `sidecar` (13 subcommands) | Neural sidecar lifecycle |
| Synergy | `synergy status`, `synergy check`, `synergy migrate` | Claude Code optimization |
| Data | `data status`, `data audit`, `data export`, `data export-auto`, `data check`, `data inspect`, `data stats`, `data quality` | Training data management |
| Plugins | `plugin list`, `plugin install` | Plugin management |
| Tools | `extract-symbols`, `embeddings check`, `mcp`, `demo` | Utilities |

Run `mdemg --help` or `mdemg <command> --help` for full usage. See the [CLI Reference](https://github.com/reh3376/mdemg/blob/main/docs/user/cli-reference.md) for complete documentation.

---

## API

The MDEMG server exposes 40+ HTTP endpoints organized into these groups:

- **Health** — `/healthz`, `/readyz`
- **Memory** — `/v1/memory/retrieve`, `/v1/memory/ingest`, `/v1/memory/consolidate`, `/v1/memory/stats`
- **Conversation** — `/v1/conversation/observe`, `/v1/conversation/recall`, `/v1/conversation/resume`
- **Learning** — Edge management, co-activation tracking, decay
- **Jiminy** — Guidance, constraint tracking, escalation
- **RSIC** — Self-improvement cycles, health metrics
- **Spaces** — Multi-space CRUD, export/import
- **Plugins** — Registry, lifecycle management

See the [API Reference](https://github.com/reh3376/mdemg/blob/main/docs/user/api-reference.md) for all endpoints with request/response shapes and curl examples.

---

## Documentation

| Guide | What it covers |
|-------|---------------|
| [Beta Testing Guide](mdemg_beta_testing.md) | Installation, prerequisites, step-by-step verification (59 tests across 6 tiers) |
| [CLI Reference](https://github.com/reh3376/mdemg/blob/main/docs/user/cli-reference.md) | All commands, flags, defaults, examples, environment variables |
| [API Reference](https://github.com/reh3376/mdemg/blob/main/docs/user/api-reference.md) | Every HTTP endpoint with request/response shapes and curl examples |
| [CMS & RSIC Guide](https://github.com/reh3376/mdemg/blob/main/docs/user/cms-rsic-guide.md) | Conversation memory, observation types, surprise scoring, self-improvement cycles |
| [Ingestion Guide](https://github.com/reh3376/mdemg/blob/main/docs/user/ingestion-guide.md) | All 8 ingestion methods — codebase, scraper, Linear, webhooks, file watcher, API |
| [Ingest Performance](https://github.com/reh3376/mdemg/blob/main/docs/guides/ingest-performance.md) | Speed presets, tuning flags, and performance tips for codebase ingestion |
| [Docker Deployment](https://github.com/reh3376/mdemg/blob/main/docs/user/quickstart-docker.md) | Docker Compose setup, port configuration, service management |
| [Multi-Instance Guide](https://github.com/reh3376/mdemg/blob/main/docs/user/multi-instance.md) | Running multiple MDEMG instances, resource requirements, known limitations |
| [Changelog](CHANGELOG.md) | Release history from v0.1.0 to current |

---

## Configuration

Priority chain (lowest to highest):

```
defaults → .mdemg/config.yaml → system keychain → .env → environment variables → CLI flags
```

`mdemg init` generates both `.mdemg/config.yaml` and `.env` with all port assignments and service credentials. In Docker Compose deployments, `.env` is the primary configuration file.

```bash
mdemg config show       # View effective config with source annotations
mdemg config validate   # Validate syntax and probe connectivity
```

---

## Links

- [Source Code](https://github.com/reh3376/mdemg)
- [Releases](https://github.com/reh3376/mdemg/releases)
- [Docker Deployment Guide](https://github.com/reh3376/mdemg/blob/main/docs/user/quickstart-docker.md)
- [Issues](https://github.com/reh3376/mdemg/issues)
