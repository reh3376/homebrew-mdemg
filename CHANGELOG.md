# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.8.1] - 2026-04-12

### Added
- **/strict Mode** — Deterministic agent governance (STRICT-P0P1 sprint):
  - `POST /v1/jiminy/strict` — per-session strict mode toggle; state file at `~/.mdemg/.jiminy-strict-mode`
  - `POST /v1/jiminy/reformulate` — imperative directive generation (~430 → ~200-350 tokens)
  - `POST /v1/jiminy/classify` — response classification with graduated enforcement (SURFACED=pass, WARNED+=deny)
  - `pre-write-check.py` PreToolUse hook — blocks Write/Edit when escalated constraint violated; fail-open when server unreachable
- **Escalation persistence** — write-behind `EscalationStore` persists J12 state to Neo4j, survives server restarts
- **T1/T2 comprehension fix** — bootstrap header + decoding instruction injected with T1/T2 guidance; comprehension gate auto-downgrades T1 when follow rate < threshold
- New config: `JIMINY_ESCALATION_PERSIST_ENABLED`, `JIMINY_STRICT_STATE_PATH`, `J17_T1_COMPREHENSION_GATE`

## [0.8.0] - 2026-04-10

### Added
- **Server-native alert evaluator** — 13 TSDB-query alert rules evaluated natively (Grafana no longer required)
- **Goroutine supervisor** — monitors background goroutines with panic recovery, auto-restart, exponential backoff
- **Alert dispatcher** — file backend with atomic JSON writes, macOS notification support, cooldown dedup
- **Hook alert delivery** — `prompt-context.sh` and `session-start.sh` display pending alerts
- **LLM retry with exponential backoff** — retries on 429/503 with `Retry-After` support
- **Enhanced `/healthz`** — subsystem checks with `status: "degraded"` when unhealthy
- **LLM consecutive failure alert** — fires after N consecutive failures (default: 3)
- **Health prober** — periodic API/Neo4j/TSDB/sidecar probing with alert callbacks
- New config: `ALERT_ENABLED`, `ALERT_EVALUATOR_ENABLED`, `ALERT_EVALUATOR_INTERVAL_SEC`, `LLM_RETRY_ENABLED`, `LLM_RETRY_MAX_ATTEMPTS`, `LLM_CONSECUTIVE_FAILURE_THRESHOLD`, `HEALTH_PROBE_ENABLED`, `HEALTH_PROBE_INTERVAL_SEC`

## [0.7.4] - 2026-04-08

### Added
- Code comprehension feedback loop (feature-gated: `JIMINY_CODE_REGEN_ENABLED`)
- Embedding cache TTL (`NODE_EMBEDDING_CACHE_TTL_SEC`, default: 3600)
- TSDB schema version CI check
- Goroutine semaphore (RSIC dispatch concurrency cap: 50)
- Synergy file reader for RSIC health assessment
- NLI bias alert consumer

### Fixed
- 10 P1 fixes: sequence counter resume, tier predictor timeout, training TOCTOU, watchdog ctx race, postReport lock, task cycle stale reads, TryLock skip reporting, empty-graph cascade guard, healthcheck port parameterized, trust store consistency documented
- 11 P2 fixes: TTL raised to 86400, EdgeTypeStrategy validation, decay NaN guard, CONFLICTS_WITH MERGE, LLM handler 30s timeouts, LISTEN_PORT removal, stop_grace_period, AUTH_API_KEYS fallback, TSDB schema v10, dashboard sparse-event panels
- All fixes live-validated (zero failures, zero regressions)

## [0.7.3] - 2026-04-07

### Added
- Server-native alert evaluator (13 TSDB-query rules, replaces Grafana requirement)
- Goroutine supervisor with panic recovery and auto-restart
- Alert dispatcher with file + macOS notification backends
- LLM retry with exponential backoff (429/503 only)
- Enhanced `/healthz` with subsystem checks and degraded status
- Health prober with alert callbacks
- 7 new Grafana alert rules (28 total)

### Fixed
- Trust persistence goroutine leak
- Dead startup code wired (`CONTEXT_COOLER_ENABLED`, `WEEKLY_GAP_INTERVIEWS_ENABLED`)
- Hook alert banners broken on macOS (`timeout` command unavailable)

### Changed
- Default LLM model: gpt-5-nano → gpt-4.1-nano (non-tool-use, 2x cheaper)
- Fine-tuning plan updated to v4.0
- Circuit breaker expansion to outcome classifier and codegen

## [0.7.2] - 2026-04-06

### Fixed
- Trust accrual: partial_compliance excluded from scoring (threshold 0.5 → 0.20)
- Trust accrual: OutcomePartialCompliance missing from aggregate
- WarmStore upward-crossing invalidation (T3→T2, T2→T1)
- J8 synthesis overrides T1 compact encoding (skipped at T1 trust)
- Partial compliance added to metrics pipeline and dashboard

### Investigation
- J17 tier promotion analysis: T3→T2→T1 validated in 15 cycles

## [0.7.1] - 2026-04-06

### Fixed
- Negation detection false positives (deferred to LLM Tier 2)
- LLM classification prompt: action summary format guidance
- Source diversity metric query (COALESCE on guidance_type)
- Outcome classifier: `not_applicable` for unrelated guidance
- Guidance content normalization for embedding similarity
- LLM tier enabled by default, heuristic fallback to partial_compliance
- Similarity thresholds adjusted (high: 0.55, low: 0.20)
- GUIDANCE_OUTCOME edges filtered to typed nodes only
- Feedback cooldown reduced from 30s to 10s

### Added
- `guidance_type` property on GUIDANCE_OUTCOME edges
- Jiminy outcome env vars in Docker Compose templates
- DocComment enrichment for structural summaries

### Investigation
- Jiminy guidance effectiveness analysis and diagnostic script

## [0.7.0] - 2026-04-05

### Added
- V0024 migration for signal learner persistence
- Weekly maintenance LaunchAgent (`com.mdemg.maintenance`)
- Config cross-field validation (`Config.Validate()`)
- Pool metrics collector for Neo4j connection monitoring
- NilSafe embedder wrapper

### Fixed
- RRF activation seeding bias (P0) — BM25-only candidates no longer suppressed
- Pre-bash guard fail-open (P0) — now fails closed on pattern decode error
- Schema version drift (P0) — all deploy configs at version 23, CI validated
- Signal learner ephemeral (P1) — persists to Neo4j across restarts
- Background goroutine lifecycle (P1) — WaitGroup tracking, shutdown wait
- Consolidation race (P1) — per-space TryLock
- Cache key gap (P1) — IncludeGlobalSpace, CodeOnly, TranslateIntent included
- Learning writeback timeout (P2) — 10s context timeout
- Sidecar confidence floor (P2) — applied uniformly to NLI scorer

## [0.6.1] - 2026-04-05

### Fixed
- `mdemg init` propagates Jiminy config to `.env` for Docker Compose (#265)
- Hook templates use runtime port discovery instead of hardcoded URL (#267)
- Hook templates include `# MDEMG` marker for lifecycle management

### Changed
- `mdemg init` force-updates hooks to latest templates on re-run

## [0.5.4] - 2026-04-03

### Added
- Multi-instance deployment guide with resource measurements
- TSDB backup before teardown (Phase 0b with `--export`)
- Upgrade automation: Docker instances updated automatically after binary upgrade
- New flags: `--no-docker`, `--docker-only` for upgrade command

### Fixed
- `mdemg teardown` doesn't stop Docker Compose services
- Teardown silently destroys TSDB training data

## [0.5.3] - 2026-04-03

### Added
- `WithSpaceID` context helper — correct TSDB space attribution for all retrieval LLM consumers
- Campaign env vars in compose template (`QUERY_CLASSIFY_ENABLED`, `INTENT_ENABLED`, `JIMINY_ENABLED`, `EMERGENCE_ENABLED`, `LLM_INTERACTION_LOGGING`)
- Campaign task activation prompt during interactive `mdemg init`
- 19-test automated live validation script (`scripts/live_validation.py`)
- Weekly cron safety net for Docker image publishing

### Fixed
- TSDB schema version stuck at 7 (migration 010 corrects to 10)

## [0.5.2] - 2026-04-03

### Added
- `AUTO_MIGRATE` env var for unified Neo4j + TSDB migration in Docker
- Neural-sidecar Docker image published to GHCR
- `docker-publish.yml` `workflow_run` trigger from Release workflow
- LaunchAgent templates embedded in binary
- `session_id` field on `/v1/memory/retrieve` and `/v1/memory/consult`

### Fixed
- neural-sidecar `build: ./neural` breaks non-repo installs
- Fresh Neo4j crash-loops (no AUTO_MIGRATE for first-start schema)
- Docker Publish CI stuck at v0.3.4
- `mdemg data` commands don't load `.env`
- `mdemg service install` fails for Homebrew users
- session_id, space_id, and recorder initialization order in TSDB pipeline
- Export instance_id auto-detection mismatch (silent 0 rows)

## [0.5.1] - 2026-04-02

### Added
- Docker compose file embedded in binary — `mdemg init` works without repo checkout
- `mdemg data export-auto` for automated training data export with retention management
- `mdemg data check --pre-campaign` with 8 automated validation checks
- Training export LaunchAgent (24h timer via `mdemg service install`)
- vllm-mlx setup guide for local Qwen3-30B-A3B inference
- Full LoRA training pipeline: `train_ft.py`, `evaluate_ft.py`, `regression_gate.py`, `quantize_deploy.py`
- Teacher distillation (`teacher_distill.py`) for synthetic data generation
- 21 GRPO reward functions (`reward_functions.py`) for reinforcement learning
- `mlx-lm` optional dependency in `[lora]` extras group

### Fixed
- `mdemg init` fails for Homebrew users (docker-compose.yml missing from tarball)
- `mdemg tsdb start/stop` fails outside repo checkout

## [0.5.0] - 2026-04-02

### Added
- QueryClassifier wired into retrieval pipeline (`QUERY_CLASSIFY_ENABLED`)
- `session_id` flows from API requests into training data records
- Campaign task activation guide

## [0.4.2] - 2026-04-01

### Added
- Instance ID on all training tables for multi-instance isolation
- System RAM detection + Neo4j memory tiering during init
- Automatic `space_id` and `instance_id` backfill on server startup

### Fixed
- All 16 LLM consumers wrote empty `space_id`
- Neo4j defaults consuming 5GB+ on 32GB machines

## [0.4.1] - 2026-03-31

### Added
- Per-field privacy skip patterns for multi-table export
- Schema version 8 (instance_id migration)

## [0.4.0] - 2026-03-31

### Added
- Edge binary CI: platform-specific CLI binaries built on every merge to main
- `mdemg upgrade --edge`: self-update to latest edge build with SHA-256 verification
- `mdemg upgrade --dry-run`: check for updates without installing
- `mdemg update` alias for `mdemg upgrade`
- Session-start version mismatch detection between CLI binary and running server
- Install script edge channel: `CHANNEL=edge` support for bare binary downloads
- Healthz endpoint now includes `commit` field for version comparison

## [0.3.4] - 2026-03-24

### Fixed
- TSDB auto-migrate now respects `TSDB_AUTO_MIGRATE` environment variable in Docker deployments

### Added
- Data governance documentation

## [0.3.0] - 2026-03-19

### Added
- Docker Compose as primary deployment (5 services: Neo4j, TimescaleDB, MDEMG server, neural sidecar, Grafana)
- Browser dashboard at `http://localhost:9999/ui/` with 9 tabs (Status, Memory, Learning, Config, Logs, RSIC, Plugins, Features, Backups)
- Grafana dashboards for Jiminy, J17, Neo4j, and fine-tuning metrics
- TimescaleDB for training data collection
- Jiminy inner-voice guidance system
- `mdemg service` command group for OS-level background services (install, uninstall, status, restart, logs)
- `mdemg teardown` to remove all MDEMG artifacts from a project
- `mdemg sidecar` command group (13 subcommands) for sidecar lifecycle management
- `mdemg synergy` command group for Claude Code integration optimization
- `mdemg ingest-claude-md` for ingesting Claude Code memory files
- `mdemg data` command group for training data management
- `mdemg tsdb` command group for TimescaleDB management
- Interactive credential prompts in `mdemg init` (Neo4j, Grafana, TimescaleDB passwords)
- Port conflict detection and automatic free port assignment during init
- MCP/IDE auto-detection (Cursor, VS Code, Claude Code) during init
- Backup UI tab in browser dashboard

### Deprecated
- `mdemg db start` and `mdemg db stop` — use `docker compose up -d` / `docker compose down` instead

## [0.2.15] - 2026-03-19

### Added
- Linux distribution via install script (`scripts/install.sh`)
- AutoResearch integration

## [0.2.0] - 2026-03-10

### Added
- UxTS plugin (installed to `share/mdemg/plugins/uxts-module/`)
- MCP server for IDE integration (`mdemg mcp`)
- Backup CLI (`mdemg db backup`)
- Space management commands (export, import, copy, rename, delete, list, info)
- Embedding provider validation and secret redaction in status output

### Changed
- Default embedding model switched to `text-embedding-3-large` (3072 dimensions)
- Configurable RSIC history cap

## [0.1.0] - 2026-02-28

### Added
- Initial release of macOS Homebrew tap for MDEMG
- Homebrew formula for easy installation on macOS (Intel and Apple Silicon)
- Tab completion setup for zsh/bash
- Man pages integration
- Support for macOS 12 (Monterey) and later
- Docker Desktop integration for Neo4j database management
- Configuration management via `.mdemg/config.yaml`
- Support for OpenAI and Ollama embedding providers
- Git hooks for auto-ingestion on commits

[Unreleased]: https://github.com/reh3376/homebrew-mdemg/compare/v0.8.1...HEAD
[0.8.1]: https://github.com/reh3376/homebrew-mdemg/compare/v0.8.0...v0.8.1
[0.8.0]: https://github.com/reh3376/homebrew-mdemg/compare/v0.7.4...v0.8.0
[0.7.4]: https://github.com/reh3376/homebrew-mdemg/compare/v0.7.3...v0.7.4
[0.7.3]: https://github.com/reh3376/homebrew-mdemg/compare/v0.7.2...v0.7.3
[0.7.2]: https://github.com/reh3376/homebrew-mdemg/compare/v0.7.1...v0.7.2
[0.7.1]: https://github.com/reh3376/homebrew-mdemg/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/reh3376/homebrew-mdemg/compare/v0.6.1...v0.7.0
[0.6.1]: https://github.com/reh3376/homebrew-mdemg/compare/v0.5.4...v0.6.1
[0.5.4]: https://github.com/reh3376/homebrew-mdemg/compare/v0.5.3...v0.5.4
[0.5.3]: https://github.com/reh3376/homebrew-mdemg/compare/v0.5.2...v0.5.3
[0.5.2]: https://github.com/reh3376/homebrew-mdemg/compare/v0.5.1...v0.5.2
[0.5.1]: https://github.com/reh3376/homebrew-mdemg/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/reh3376/homebrew-mdemg/compare/v0.4.2...v0.5.0
[0.4.2]: https://github.com/reh3376/homebrew-mdemg/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/reh3376/homebrew-mdemg/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/reh3376/homebrew-mdemg/compare/v0.3.4...v0.4.0
[0.3.4]: https://github.com/reh3376/homebrew-mdemg/compare/v0.3.0...v0.3.4
[0.3.0]: https://github.com/reh3376/homebrew-mdemg/compare/v0.2.15...v0.3.0
[0.2.15]: https://github.com/reh3376/homebrew-mdemg/compare/v0.2.0...v0.2.15
[0.2.0]: https://github.com/reh3376/homebrew-mdemg/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/reh3376/homebrew-mdemg/releases/tag/v0.1.0
