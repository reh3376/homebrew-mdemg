# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

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

[Unreleased]: https://github.com/reh3376/homebrew-mdemg/compare/v0.5.3...HEAD
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
