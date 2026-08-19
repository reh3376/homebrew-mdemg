# MDEMG — Multi-Dimensional Emergent Memory Graph

> **👋 Beta tester?** Start here → **[README_BETA.md](README_BETA.md)** — single-page onboarding index with install, testing plan, UIs, backups, troubleshooting, and reporting.

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
- Self-update with SHA-256 verification (`mdemg upgrade`, `mdemg upgrade --edge`). Automatically updates running Docker instances.
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
| macOS 12+ | Apple Silicon (arm64) | `brew trust reh3376/mdemg`, then `brew tap reh3376/mdemg`, then `brew install mdemg` |
| Linux | x86_64, arm64 | [Install script](https://github.com/reh3376/mdemg/blob/main/scripts/install.sh) |
| Windows | WSL2 | [Install script](https://github.com/reh3376/mdemg/blob/main/scripts/install.sh) (inside WSL2) |

All platforms require Docker Desktop (or Docker Engine on Linux) for the service stack.

---

## Quick Start

```bash
# macOS
brew trust reh3376/mdemg    # REQUIRED before first install (Homebrew's untrusted-tap policy)
brew tap reh3376/mdemg
brew install mdemg

# Linux / WSL2
curl -fsSL https://raw.githubusercontent.com/reh3376/mdemg/main/scripts/install.sh | bash
```

> Without `brew trust`, `brew install` fails with a cryptic Sorbet stack trace — this is Homebrew's default-blocks-untrusted-taps policy in current Homebrew versions, not an MDEMG bug.

```bash
cd ~/your-project
mdemg init           # Interactive wizard — generates .env, starts 5 Docker services
mdemg ingest --path . # Ingest codebase into the knowledge graph
open http://localhost:9999/ui/  # Browser dashboard
```

### Optional: Pull the local LLM (`mdemg-llm-v1`)

If you want MDEMG to run its production LLM locally (instead of using OpenAI), pull the fine-tuned `mdemg-llm-v1` model. The model is hosted on **Ollama Library** at https://ollama.com/reh3376/mdemg-llm-v1 in 3 quant tiers:

```bash
brew install ollama          # one-time — Ollama is the distribution channel (not the inference runtime)
mdemg model pull             # RAM-auto picks Q4_K_M / Q5_K_M / Q8_0 for your hardware
# → prints the MDEMG_MODEL_PATH line to add to your .env, plus the launchctl restart command
```

Three quants serve three RAM tiers:

| Quant | GGUF size | Min RAM | Recommended RAM | Notes |
|---|---|---|---|---|
| Q4_K_M | ~8.4 GB | 12 GB | 16 GB | Smallest fidelity tier |
| Q5_K_M | ~9.8 GB | 14 GB | 24 GB | **Production canonical** (Phase 13.5) |
| Q8_0 | ~14.6 GB | 20 GB | 32 GB | Highest fidelity; ~50% bigger for marginal gain on a 14B fine-tune |

Direct Ollama Library pages:
- https://ollama.com/reh3376/mdemg-llm-v1:Q4_K_M
- https://ollama.com/reh3376/mdemg-llm-v1:Q5_K_M
- https://ollama.com/reh3376/mdemg-llm-v1:Q8_0

> **Note**: MDEMG uses `llama.cpp llama-server` (Phase 13.5) as the inference runtime, *not* Ollama's runtime. Ollama is only the distribution channel — `mdemg model pull` invokes `ollama pull` under the hood, then symlinks the GGUF blob into `~/.mdemg/models/` so `llama-server` can serve it on port 8102. Operators on hardware where Ollama's runtime is broken (M5 + macOS 26.3.x per the upstream issue tracker) still get a working local LLM through this path.

**Manage your pulled models:**

```bash
mdemg model list       # tabular: name, symlink target, size, SHA prefix
mdemg model verify     # re-check SHA256 against the embedded quant manifest
mdemg model where      # print the resolved local path (for shell scripting)
mdemg model remove --yes  # unlinks symlink + invokes `ollama rm <tag>`
```

**Explicit quant selection** (skip RAM auto-detection):

```bash
mdemg model pull --quant Q4_K_M
mdemg model pull --quant Q5_K_M
mdemg model pull --quant Q8_0
```

**Forks and custom variants**: every operator-visible value is dynamic. Publish your own variant under a different namespace:

```bash
MDEMG_MODEL_NAMESPACE=acme MDEMG_MODEL_NAME=custom-llm mdemg model pull
# or
mdemg model pull --namespace acme --name custom-llm --quant Q5_K_M
```

Full Configurability Contract (11 env vars + flags) documented at [`docs/features/local-model-distribution.md`](https://github.com/reh3376/mdemg/blob/main/docs/features/local-model-distribution.md).

If you don't want a local LLM, skip this step — MDEMG falls back to OpenAI (default `gpt-5.4-mini`).

### Model versioning + upgrade path

MDEMG's local LLM is a **versioned production model**. Each version has its own name on Ollama Library; `mdemg model pull` fetches by `--namespace/--name` (defaults `reh3376/mdemg-llm-v1`).

**Current default: `mdemg-llm-v1`**
- Base: Qwen3-14B-4bit (`mlx-community/Qwen3-14B-4bit`)
- Fine-tune: Phase 5 SFT (dense), served as GGUF Q5_K_M via `llama-server` on port 8102
- Benchmark aggregate: **0.9188** on the 16-task augmented eval (current honest number; see `docs/development/ape-reflect-eval-refresh-001/`)
- Ships today; this is what `brew install mdemg && mdemg model pull` gets you

**Coming: `mdemg-llm-v2`** (not yet shipped — tracking task [`#134`](https://github.com/reh3376/mdemg/issues) HOMEBREW-INSTALLER-QWEN-UPDATE-001)
- Base: new 27B Qwen (specific variant per task #91 MODEL-SWAP-QWEN27B-EVAL follow-up)
- Fine-tune: retrained on Phase E2's stripped corpus (~7,503 rows; fact-recall now handled by MDEMG's memory substrate via retrieval + content projection per PHASE-E1/E2)
- Distribution channel: same as v1 — Ollama Library under `reh3376/mdemg-llm-v2`
- v1 remains fetchable indefinitely for rollback

**When v2 ships, upgrade like this:**

```bash
# 1. Pull the new model (RAM-auto picks quant, same as v1)
mdemg model pull --name mdemg-llm-v2

# 2. Update your .env — replace the MDEMG_MODEL_PATH line
#    with the path printed by step (1), e.g.:
#    MDEMG_MODEL_PATH=/Users/you/.mdemg/models/mdemg-llm-v2.Q5_K_M.gguf

# 3. Restart llama-server so it loads the new weights
launchctl kickstart -k gui/$UID/com.mdemg.llama-server

# 4. Verify the swap
curl -s http://127.0.0.1:8102/v1/models | jq .data[0].id
mdemg model list      # confirm v2 symlink + size
```

> **Note (2026-08-19)**: today, model activation is env-var + `launchctl kickstart` (steps 2-3 above). A `mdemg model use <name>` shorthand may ship as part of task #134 to collapse steps 2-3 into one command; if it lands, the docs will reflect it. The env-var path continues to work regardless.

**Rollback to v1:**

```bash
# Point .env MDEMG_MODEL_PATH back at the v1 GGUF (still on disk)
mdemg model list      # shows both v1 + v2 pulled, with local paths
# Edit .env → MDEMG_MODEL_PATH=/path/from/v1/row
launchctl kickstart -k gui/$UID/com.mdemg.llama-server
```

v1 is not deleted by pulling v2 (each version is a distinct Ollama tag + a distinct local symlink under `~/.mdemg/models/`). To free the v1 disk space explicitly: `mdemg model remove --name mdemg-llm-v1 --yes`. Rollback requires re-pulling if you removed.

**Which version is running right now?**

```bash
curl -s http://127.0.0.1:8102/v1/models | jq .data[0].id       # what llama-server loaded
mdemg model list                                                # what's pulled locally
```

The GA release notes ([`docs/releases/`](https://github.com/reh3376/mdemg/tree/main/docs/releases)) will name the current default model + version for every ship. When v2 lands, its release note will document the aggregate-benchmark result vs v1's 0.9188 baseline and any operator-visible behavior change.

---

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

## What's New in v0.11.0-beta.1 (First Beta Release)

**Ship date:** 2026-08-06 | **Delta:** ~142 sprints, ~962 commits since v0.10.1 (2026-06-09)

This is the first beta release — the goal is a stable, effective, and easy-to-operate MDEMG that testers can install cleanly and use for real work.

**Fresh-install UX** (biggest tester-visible changes):
- `mdemg init --defaults` now works WITHOUT an `OPENAI_API_KEY` — falls back to a **disabled mode** where ingest, retrieval by BM25, dashboard, and observation writes all work. LLM synthesis + Jiminy + vector retrieval need an operator opt-in. See the init's printed next-steps for the 2 paths (OpenAI or Ollama).
- `RSIC_PROTECTED_SPACES` is auto-seeded with the newly-created space — no more scary "destructive actions have no space protection" warning on first `config validate`.
- `mdemg config validate` distinguishes **"services not started"** (config fine, exit 0) from **"broken config"** (exit 1). Fresh install → `docker compose up -d` → validate now tells you exactly what to do next.
- `POST /v1/conversation/observe` works in disabled mode — write observations without an embedder configured.

**Beta pipeline arcs shipped this cycle**:
- **Jiminy enforcement** — Jiminy is now an enforcer (not advisory) with 5-layer strict guards on RSIC auto-execute, operator override CLI + audit trail, missed-violation detector, HITL bridge for corrections.
- **HITL curation** — invariant-preserving auto-dismiss, source-side quality gate on contradicted drafts, scheduled autograde loop, dedicated Grafana dashboard.
- **Retrieval quality** — post-rerank near-duplicate suppression, concrete-recall + post-rerank quota promotion, reverse-lookup filesystem-grep bridge, Go IMPLEMENTS via `go/types` (194+ typed-semantic edges).
- **FT recursive-retrain loop** — full production path (Phase 6a → 9) with drift-triggered retrain + 3-layer defended promotion + auto-rollback.

**Full changelog**: [`CHANGELOG.md`](https://github.com/reh3376/mdemg/blob/main/CHANGELOG.md) has all 142 sprints with technical detail + arch-rule pins.

**Beta testers — start here**: [`mdemg_beta_testing.md`](mdemg_beta_testing.md) is the 62-test plan across 7 tiers, ~90-120 min end-to-end. Report issues at https://github.com/reh3376/mdemg/issues/new/choose.

---

## Upgrading

### Homebrew (recommended)

```bash
brew upgrade mdemg
```

This updates the CLI binary and automatically pulls latest Docker images for all running MDEMG instances. No manual `docker compose pull` needed.

### Self-update

```bash
mdemg upgrade
```

Same as brew upgrade but downloads directly from GitHub Releases. Also updates running Docker instances.

### Docker instances only

```bash
mdemg upgrade --docker-only
```

Updates Docker images and restarts containers without changing the binary.

---

## Uninstall

### Per-Project Teardown

Remove MDEMG from a single project. This stops all Docker Compose services, removes volumes, and cleans up config files:

```bash
cd /path/to/your/project
mdemg teardown --yes          # Stops 5 Docker services, removes volumes, cleans config
```

Add `--keep-data` to preserve the Neo4j graph data, or `--export` to export data before teardown.

### Full System Removal

Remove MDEMG entirely from your machine:

```bash
# 1. Teardown each project
cd /path/to/project && mdemg teardown --yes

# 2. Remove LaunchAgents (macOS)
mdemg service uninstall

# 3. Remove the binary
brew uninstall mdemg           # Homebrew
# sudo rm /usr/local/bin/mdemg # Linux

# 4. Remove global config and data (optional)
rm -rf ~/.mdemg
```

### Graph Maintenance (Without Uninstalling)

For ongoing graph health without removing MDEMG:

```bash
# Combined maintenance cycle (decay + prune)
mdemg maintenance --space-id <your-space> --dry-run        # Preview
mdemg maintenance --space-id <your-space> --dry-run=false   # Execute

# Or run individually
mdemg decay --space-id <your-space> --dry-run=false
mdemg prune --space-id <your-space> --dry-run=false

# Graph repair (before upgrades or to fix issues)
mdemg graph repair --space-id <your-space> --dry-run=false

# Fill missing embeddings
mdemg embeddings backfill --space-id <your-space>
```

See the [CLI Reference](https://github.com/reh3376/mdemg/blob/main/docs/user/cli-reference.md) for all flags and thresholds.

---

## Links

- [Source Code](https://github.com/reh3376/mdemg)
- [Releases](https://github.com/reh3376/mdemg/releases)
- [Docker Deployment Guide](https://github.com/reh3376/mdemg/blob/main/docs/user/quickstart-docker.md)
- [Issues](https://github.com/reh3376/mdemg/issues)
