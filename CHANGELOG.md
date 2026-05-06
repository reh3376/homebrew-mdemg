# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.9.0] - 2026-05-06

### Breaking
- **Phase 13.5 — Production LLM runtime port 8101 → 8102.** `mlx_lm.server` (port 8101) is replaced by `llama.cpp llama-server` (port 8102) serving `mdemg-llm-v1.Q5_K_M.gguf`. The mlx_lm.server backend exhibited unbounded KV-cache → Metal-OOM → SIGABRT crashes every ~14 min on M5 Max + macOS 26.3.x; llama.cpp has architecturally-bounded KV cache (`--ctx-size × --parallel`) and stays HTTP-alive on OOM. Bake-off result: 0 crashes / 160 min / 301 calls; latency p50 17s → 3.0s (5.6× faster); UVTS quality at perfect parity (0.396 = 0.396). **Migration:** edit `.env` and replace every occurrence of `:8101` with `:8102`. The `com.mdemg.llama-server.plist` LaunchAgent is auto-installed via the formula's `post_install` hook.
- **Phase 13.6 — `MLX_*` env vars renamed to `LLM_*`.** Watchdog/preflight env-var family migrated for backend-agnosticism. Legacy `MLX_*` names continue to work but emit `WARN config: env var deprecated, please rename` at boot. Aliases removable ≥1 release cycle from this commit. Migration: `MLX_WATCHDOG_ENABLED` → `LLM_WATCHDOG_ENABLED`, `MLX_PROBE_INTERVAL_SEC` → `LLM_PROBE_INTERVAL_SEC`, `MLX_PROBE_TIMEOUT_SEC` → `LLM_PROBE_TIMEOUT_SEC`, `MLX_FAIL_FAST_ENABLED` → `LLM_FAIL_FAST_ENABLED`, `MDEMG_ALLOW_NO_MLX` → `MDEMG_ALLOW_NO_LLM`.

### Added
- **Phase 14 — Sparse Retrieval Gate.** Note 06 percentile-activation gate at `internal/retrieval/gate.go` operates post-aggregation pre-rerank. **Default-on** since Phase 14.1.1 hybrid 120q PASSED (mean +0.003, 0 regressions, 10 improvements): `SPARSE_RETRIEVAL_ENABLED=true`, `SPARSE_MIN_ACTIVE=15` global + `data_flow_integration` per-category override at MIN=20. Produces ~25% rerank-input reduction on most calls. Operator opt-out: `SPARSE_RETRIEVAL_ENABLED=false`. Per-call override via `?sparse=true|false`, `?sparse_percentile=N`, or `?category=...` URL params. Persists to V0019 `sparse_gate_metrics` hypertable.
- **Phase 14.2 — Context Fingerprinting + 5th RRF column.** Per-observation 256-bit sparse vectors that let retrieval discriminate the same `MemoryNode` in different contexts. **Default-on** since Phase 14.2.3 (CONTEXT_FINGERPRINT_ENABLED=true, RETRIEVAL_CONTEXT_COLUMN_ENABLED=true) after 120q full A/B PASSED (mean +0.009, std -0.023, 11 improvements, 0 regressions). Per-category weight overrides via `RETRIEVAL_CONTEXT_COLUMN_CATEGORY_WEIGHTS` JSON env. Vector-based query→fingerprint derivation when `?context=auto` URL param set. Strict mode (`?strict_context=true`) drops candidates below `RETRIEVAL_CONTEXT_STRICT_THRESHOLD` (0.25 Jaccard). Backfill CLI: `mdemg migrate context-fingerprint --space-id <id>`. Schema: V0025+V0026+TSDB V0020.
- **Phase 13 + 13.1 — Column-Voting Retrieval.** RRF aggregator over 4 columns (Embedding + BM25 + Graph + Structural) with `consensus_strength` output signal. **Default-on** since Phase 13.1 (`RETRIEVAL_COLUMN_VOTING_ENABLED=true`) — embedding-heavy weights `0.50/0.20/0.15/0.15` passed full 120q UVTS A/B with mean +0.023 (+5.9%), 30 improvements. Per-column suppression knobs + per-column weights + `RETRIEVAL_RRF_K` (60) + `RETRIEVAL_STRUCTURAL_HOPS` (2) + `RETRIEVAL_COLUMN_TIMEOUT_FRACTION` (0.8). Operator opt-out: `RETRIEVAL_COLUMN_VOTING_ENABLED=false`.
- **Phase 12 — UVTS Activation.** Universal Validation Test Specification framework activated. New `make test-uvts-{lint,quick,full}` targets. A/B compare harness at `docs/tests/uvts/runners/uvts_ab_compare.py`. Persists to V0016 `uvts_runs` + `uvts_results` (TSDB schema 15 → 16).
- **Phase 10.5 — UBENCH framework.** Promotes `neural.benchmarks.run_benchmark` to a UxTS-pattern framework. New `docs/tests/ubench/` tree with `make test-ubench{,-lint,-contract,-run}`. Pytest contract: `pytest docs/tests/ubench/contracts/`. Spec at `docs/tests/ubench/specs/mdemg.ubench.json` (17 specs / 108 rows / `min_rows_per_task=3`).
- **Phase 11.6.3 — MLX Watchdog.** Always-on policy enforced (`LLM_WATCHDOG_ENABLED=true` default). Probe `<endpoint>/v1/models` every 5s with 2s timeout; state machine `up → degraded → down` with hysteresis. Fast-fail gate short-circuits retry math when state=Down. New `mdemg watchdog status` CLI. 3 Prometheus metrics. Bypass via `MDEMG_ALLOW_NO_LLM=1`.
- **Claude Code GitHub App workflows.** `@claude` mention handler (`claude.yml`) and auto PR review (`claude-code-review.yml`).

### Changed
- **Schema versions bumped:** Neo4j to V0026, TSDB to V0020 (was V0023/V0019 in v0.8.5). `auto-migrate` runs both on startup.
- **`mdemg-llm-v1` is the production LLM model** (Phase 5 dense Qwen3-14B fine-tune; aggregate 0.8389 on augmented eval). Served at GGUF Q5_K_M via llama-server.
- **Phase 11.5e rollback:** Phase 5 base reinstated as production canonical. Stage-1 distill (`-distill-stage1/`) and Phase 11 GRPO (`-rl-run7/`) archived; both were net-negative on the augmented 16-task eval.

### Deprecated
- **`MLX_*` env-var aliases.** Removable ≥1 release cycle from this commit (see Breaking → Phase 13.6). Migrate to `LLM_*`.
- **`mlx_lm.server` runtime path.** `~/Library/LaunchAgents/com.mdemg.mlx-server.plist.disabled-phase13_5` is preserved for emergency rollback only.

### Fixed
- **Sequence counter restored on resume.** Tier predictor timeout differentiation. Training TOCTOU fix. Watchdog ctx race guard. `postReport` lock upgrade. Task cycle version counter. Empty-graph cascade guard. Healthcheck port parameterized. EdgeTypeStrategy validation. Decay NaN guard. CONFLICTS_WITH MERGE. LLM handler timeouts. Goroutine semaphore. Embedding cache TTL. NLI bias alert consumer. Compose cleanup (`LISTEN_PORT`, `stop_grace_period`, `AUTH_API_KEYS`). Eval cache wired into `llmEvaluate()`. Dead trust store goroutine removed.

## [0.8.5] - 2026-04-20

### Added
- **DH-005: Health Formula Reweighting & Confidence-Adaptive Scoring** — `ComputeOverallHealth` rewritten as normalised weighted-confidence sum (`overall = Σ(w·c·s) / Σ(w·c)`). Dimensions without data are automatically excluded via confidence multiplier — no more 4/5/6/7-dim branch table.
  - 7 new operator weight knobs: `RSIC_HEALTH_WEIGHT_<RETRIEVAL|MEMORY|EDGE|TASK|GUIDANCE|PROTOCOL|SYNERGY>` (hybrid reliability × user-impact priors, sum = 1.00). Zero disables a dimension; negative falls back to default with warning log.
  - 7 new Prometheus gauges: `mdemg_rsic_health_<dim>_confidence` exposed via `/metrics`, persisted by TSDB writeback.
  - New Grafana "Dimension Confidence (DH-005)" row on `mdemg-rsic` dashboard distinguishes "scored 0 because broken" from "scored 0 because no data."
- **DH-004: J17 Protocol & Jiminy Dashboard Remediation** — admin endpoints + deadline-aware LLM retry:
  - `GET /v1/admin/breakers` — list all circuit breakers with state + counts (gated by `AUTH_API_KEYS`).
  - `POST /v1/admin/breakers/reset` — force a named breaker to `StateClosed` (operator escape hatch for transient breaker trips).
  - New env var `LLM_RETRY_DEADLINE_ENABLED` (default `true`) — retry once on `context.DeadlineExceeded` iff remaining context budget > 2× base delay.
  - 7 J17 sidecar env vars exposed in all compose templates: `J17_SIDECAR_URL`, `J17_SIDECAR_TIMEOUT_MS`, `J17_SIDECAR_MODE`, `J17_SIDECAR_CONFIDENCE_FLOOR`, `J17_SIDECAR_CB_FAILURE_THRESHOLD`, `J17_SIDECAR_CB_TIMEOUT_SEC`, `J17_NLI_COMPREHENSION_ENABLED`, `J17_NLI_CALIBRATION_BIAS_THRESHOLD`.
- **UAITS Framework** — Universal AI Training Specification (10th UxTS framework): 4 paradigms (SFT, DPO, RAFT, curriculum), spec-driven pipeline dispatch, DPO pair builder from `constraint_outcomes` + `llm_interactions`, new CLI `mdemg data curate` / `mdemg data validate`.
- **DOC-UPDATE-01** — documentation audit aligned user/architecture/ft-lora docs with DH-004/DH-005 runtime defaults.

### Changed
- **`CONSULTING_CLASSIFY_TIMEOUT_MS`** default bumped 15000 → 30000 (matches `JIMINY_SYNTHESIS_TIMEOUT_MS`; survives typical `gpt-5.4-mini` latency without tripping `openai-constraint-classify` breaker on one slow call).
- **`J17_SIDECAR_TIMEOUT_MS`** default bumped 200 → 1000, with 100ms floor in `FromEnv()`. NLI primary-path calls were timing out at 200ms ~56% of the time, inflating `j17_nli_mean_bias`.
- **Retrieval scoring hyperparameters** — α 0.55 → 0.60, β 0.30 → 0.20, γ 0.10 → 0.15. Single-row ρ split into layered ρ_L0 (0.05) / ρ_L1 (0.02) / ρ_L2 (0.01).
- **LLM Model Config** — standardized all LLM tasks to `gpt-5.4-mini` (from mixed `gpt-4.1`/`gpt-4o-mini`) for training-data quality during distillation campaign.

### Fixed
- **J17 Protocol Health null-tolerance** — `TicketRestoreSuccessRate` now defaults to `1.0` when `ticketRestoreTotal == 0` (healthy system with no restore events no longer drags 15% stability weight to zero).
- **NLI fallback counting gate-aware** — `RecordNLIFallback` only fires when `nliScorer.IsOperational()` (enabled + sidecar URL set). A gated-off scorer no longer inflates `j17_nli_mean_bias`.
- **Alert cooldown TOCTOU race** — atomic `cooldown.TryRecord()` replaces separate `Allow`+`Record` lock acquisitions. Fixes repeating "Jiminy Pipeline Critical" alerts.
- **Context Cooler graduation** — `CoactivateSession` now reinforces `stability_score` on every session observation (previously only created edges, so 99.7% of conversation observations stayed volatile forever; `rsic_health_task` = 0.019).
- **ACA-BFC + DD-P1P2 hardening** — Jiminy semantic dedup (cosine similarity + fallback), temporal correction decay (`JIMINY_CORRECTION_DECAY_RATE`), bounded ticket LRU (`J17_TICKET_CACHE_SIZE`), tier-1 predictor timeout differentiation, watchdog ctx race guard, embedding cache TTL, RSIC hardening (32 findings across 6 epics), Neo4j writer for signal learner (V0024 migration), sidecar confidence floor, writeback timeout, cache key correctness, NilSafe embedder.

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
