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
| macOS 12+ | Apple Silicon (arm64) | `brew trust reh3376/mdemg && brew install mdemg` |
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

> Without `brew trust`, `brew install` fails with a cryptic Sorbet stack trace — this is Homebrew's default-blocks-untrusted-taps policy since 2024, not an MDEMG bug.

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

## Upgrading to v0.10.1

```bash
brew upgrade mdemg        # or: mdemg upgrade
docker compose up -d      # additive TSDB migrations (V0023/V0024) run automatically
```

No breaking changes from v0.10.0 — additive only. Highlights:
- **Event Graph Federation** — `mdemg eventgraph reinforcement-neighborhood` / `guidance-outcome-neighborhood` walk a node's graph neighborhood and surface the time-series events touching it.
- **`mdemg model run`** (chat with the local LLM) and **`mdemg model pull --adapter`** (smaller adapter-only download).
- **No silent failures** — scheduled backup/maintenance/export jobs now record outcomes + alert on failure or staleness.
- **Jiminy governance skill + per-conversation SessionID** — the J17 agent-governance front door; escalation isolates per conversation.

See the main repo `CHANGELOG.md` [0.10.1] for full detail.

## Upgrading to v0.10.0

```bash
brew upgrade mdemg        # or: mdemg upgrade
docker compose up -d      # TSDB V0021 model_install_events migration runs automatically
brew install ollama       # one-time, if you want the local LLM
mdemg model pull          # one-time, fetches mdemg-llm-v1 from Ollama Library
# Follow the printed instructions to set MDEMG_MODEL_PATH in .env + restart
```

No breaking changes from v0.9.0. The `mdemg model` CLI is additive; existing installs continue working unchanged. See "What's New in v0.10.0" below.

## Upgrading to v0.9.0

```bash
brew upgrade mdemg        # or: mdemg upgrade
docker compose up -d      # V0026 + TSDB V0020 migrations run automatically
mdemg service install     # optional: adds llama-server + maintenance LaunchAgents
```

> **⚠️ Breaking — local LLM endpoint port moved 8101 → 8102**
>
> v0.9.0 replaces `mlx_lm.server` (port 8101) with `llama.cpp llama-server` (port 8102) — see "What's New" below for the rationale. If your `.env` references the old port, mdemg's startup preflight will refuse to start.
>
> ```bash
> # Edit .env and replace EVERY occurrence of :8101 → :8102
> sed -i.bak 's|:8101|:8102|g' .env
>
> # Restart and verify
> docker compose up -d
> mdemg watchdog status
> ```
>
> The new `com.mdemg.llama-server.plist` LaunchAgent is auto-installed by the formula's `post_install` hook. The old `com.mdemg.mlx-server.plist` is preserved at `*.disabled-phase13_5` for emergency rollback only.

> **Deprecated env-var family — `MLX_*` → `LLM_*`**
>
> Phase 13.6 renamed the watchdog/preflight env-vars. Legacy names still work but emit `WARN config: env var deprecated, please rename` at boot. Aliases are removable ≥1 release cycle from v0.9.0.
>
> | Old | New |
> |---|---|
> | `MLX_WATCHDOG_ENABLED` | `LLM_WATCHDOG_ENABLED` |
> | `MLX_PROBE_INTERVAL_SEC` | `LLM_PROBE_INTERVAL_SEC` |
> | `MLX_PROBE_TIMEOUT_SEC` | `LLM_PROBE_TIMEOUT_SEC` |
> | `MLX_FAIL_FAST_ENABLED` | `LLM_FAIL_FAST_ENABLED` |
> | `MDEMG_ALLOW_NO_MLX` | `MDEMG_ALLOW_NO_LLM` |

**Default LLM rotation history:**
- v0.7.2: `gpt-5-nano` → `gpt-4.1-nano`
- v0.8.0: `gpt-4.1-nano` → `gpt-5.4-mini`
- v0.9.0: `gpt-5.4-mini` (cloud) → `mdemg-llm-v1` (local Qwen3-14B fine-tune via llama-server, port 8102)
- v0.10.0: model now **publicly distributed** via Ollama Library — `mdemg model pull` does the fetch + symlink + SHA-verify dance in one command

If your `.env` still pins `LLM_MODEL`, `RECLASS_MODEL`, or `RERANK_MODEL` to a prior default, either remove the override (to inherit `mdemg-llm-v1`) or set them to `gpt-5.4-mini` to keep cloud-routed inference.

See the full [Upgrade Guide](https://github.com/reh3376/mdemg/blob/main/docs/user/upgrade-guide.md) for details.

### What's New in v0.10.0

- **Local LoRA model distributed via Ollama Library** — Sprint MODEL-DIST-001. `mdemg-llm-v1` (Phase 5 dense Qwen3-14B fine-tune) now publicly available at https://ollama.com/reh3376/mdemg-llm-v1 in three quants:
  - `:Q4_K_M` — 8.4 GB, 12 GB RAM min, 16 GB recommended
  - `:Q5_K_M` — 9.8 GB, 14 GB RAM min, 24 GB recommended (production canonical)
  - `:Q8_0` — 14.6 GB, 20 GB RAM min, 32 GB recommended
- **New CLI: `mdemg model pull|list|verify|remove|where`.** One-command install path — see the "Optional: Pull the local LLM" section above in Quick Start.
- **Pluggable distribution backend.** Ollama in v1; future `MDEMG_MODEL_BACKEND=hf|s3|github-release|file` work without changing the CLI.
- **Configurability Contract.** 11 env vars + flag overrides cover every operator-visible value (namespace, name, quant allowlist, RAM-tier map, paths, manifest source). Defaults Just Work; forks override.
- **TSDB V0021 `model_install_events` hypertable.** Structured observability rows for every pull/verify/remove operation (event_type, backend_name, namespace, model_name, quant, latency, SHA, size). Grafana panels coming in Sprint B.
- **Architectural note**: Ollama is the **distribution channel**, not the inference runtime. `llama.cpp llama-server` (Phase 13.5) remains the production runtime on port 8102. `mdemg model pull` invokes `ollama pull` under the hood, then symlinks the GGUF blob into `~/.mdemg/models/` so llama-server can serve it directly. Operators on hardware where Ollama runtime is broken still get a working local LLM through this path.
- **Adapter-only path (LoRA over your own Qwen3-14B base)** deferred to Sprint MODEL-DIST-002 — MLX → PEFT → GGUF LoRA conversion tooling work. The `--adapter` flag is reserved in the CLI for forward-compat.

Feature doc: [`docs/features/local-model-distribution.md`](https://github.com/reh3376/mdemg/blob/main/docs/features/local-model-distribution.md).

### What's New in v0.9.0

- **Phase 13.5 — Production LLM runtime cutover (llama.cpp).** `mlx_lm.server` (port 8101) replaced by `llama-server` (port 8102) serving `mdemg-llm-v1.Q5_K_M.gguf`. Bake-off result: 0 crashes / 160 min / 301 calls; latency p50 17s → 3.0s (5.6× faster); UVTS quality at perfect parity. The mlx_lm.server backend exhibited unbounded KV-cache → Metal-OOM → SIGABRT crashes every ~14 min on M5 Max + macOS 26.3.x; llama.cpp has architecturally-bounded KV cache and stays HTTP-alive on OOM. **Breaking — see "Upgrading" above for the .env migration.**
- **Phase 14.x retrieval defaults flipped on.** Sparse-retrieval gate (`SPARSE_RETRIEVAL_ENABLED=true`, hybrid MIN=15 + `data_flow_integration` MIN=20) cuts ~25% of rerank input on most calls, mean parity. Context fingerprinting + 5th RRF column (`CONTEXT_FINGERPRINT_ENABLED=true`, `RETRIEVAL_CONTEXT_COLUMN_ENABLED=true`) lets retrieval discriminate the same `MemoryNode` in different contexts; 120q full A/B PASSED at mean +0.009, 11 improvements, 0 regressions. Per-category weight overrides via `RETRIEVAL_CONTEXT_COLUMN_CATEGORY_WEIGHTS` JSON env. New backfill: `mdemg migrate context-fingerprint --space-id <id>`.
- **Phase 13 + 13.1 — Column-Voting Retrieval default-on.** RRF aggregator over Embedding + BM25 + Graph + Structural columns at embedding-heavy weights `0.50/0.20/0.15/0.15`. 120q UVTS A/B: mean +0.023 (+5.9%), 30 improvements. New `consensus_strength` signal feeds DH-005 retrieval-confidence dimension and Phase 14 sparse gate.
- **Phase 13.6 — Backend-agnostic env-var rename.** `MLX_*` → `LLM_*` for the watchdog suite. Legacy aliases retained for ≥1 release cycle; deprecation log fires at boot. **See "Upgrading" above for the rename table.**
- **Phase 12 — UVTS framework activation.** `make test-uvts-{lint,quick,full}` for retrieval-quality A/B testing. New TSDB `uvts_runs` + `uvts_results` hypertables.
- **Phase 10.5 — UBENCH framework.** `make test-ubench{,-lint,-contract,-run}` wraps the Phase 10 LLM benchmark in the UxTS contract pattern. Pytest entry: `pytest docs/tests/ubench/contracts/`. Spec at `docs/tests/ubench/specs/mdemg.ubench.json`.
- **Phase 11.6.3 — MLX/LLM Watchdog default-on.** `LLM_WATCHDOG_ENABLED=true` by default. mdemg refuses to start if the LLM endpoint is unreachable. Bypass via `MDEMG_ALLOW_NO_LLM=1`. New `mdemg watchdog status` CLI for operator visibility.
- **Claude Code GitHub App workflows.** `@claude` mention handler + auto PR review.

### What's New in v0.8.5

- **DH-005 Health Formula Reweighting** — `ComputeOverallHealth` rewritten as normalised weighted-confidence sum; 7 `RSIC_HEALTH_WEIGHT_*` operator knobs (Retrieval 0.08, Memory 0.15, Edge 0.15, Task 0.20, Guidance 0.17, Protocol 0.20, Synergy 0.05); 7 new `rsic_health_<dim>_confidence` Prometheus gauges; new "Dimension Confidence" Grafana row.
- **DH-004 Dashboard Remediation** — admin breakers endpoints (`GET/POST /v1/admin/breakers[/reset]`); deadline-aware LLM retry (`LLM_RETRY_DEADLINE_ENABLED`); `CONSULTING_CLASSIFY_TIMEOUT_MS` 15000→30000; `J17_SIDECAR_TIMEOUT_MS` 200→1000; 7 J17 sidecar env vars in compose templates.
- **/strict Mode + UAITS Framework** — deterministic agent governance (`/v1/jiminy/strict|reformulate|classify`); 10th UxTS framework with DPO/RAFT/curriculum paradigms; new `mdemg data curate` / `mdemg data validate` commands.
- **ACA-BFC + DD-P1P2 hardening** — Jiminy semantic dedup, temporal correction decay, tier-1 predictor timeouts, watchdog guard, embedding cache TTL, RSIC 32-finding remediation, Neo4j signal learner persistence, alert cooldown TOCTOU race fix, context cooler stability reinforcement (99.7% volatile observations now graduate).
- **DOC-UPDATE-01** — user/architecture/ft-lora docs aligned with runtime defaults.

### What's New in v0.7.4

- DD-P1P2 deep dive bug fix campaign (10 P1 + 21 P2 fixes, all live-validated)
- Server-native alert evaluator (Grafana no longer required for alerting)
- LLM retry with exponential backoff, enhanced `/healthz` with subsystem checks
- Code comprehension feedback loop, embedding cache TTL
- Default LLM migrated to gpt-4.1-nano (non-tool-use, 2x cheaper)
- J17 tier promotion validated T3→T2→T1, Jiminy effectiveness arc complete

### Upgrading from v0.5.x to v0.6.0

If upgrading from v0.5.x, run graph repair before restarting to preserve edge weights:

```bash
brew upgrade mdemg
mdemg graph repair --space-id <your-space> --dry-run=false
docker compose up -d
```

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
