# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

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

[Unreleased]: https://github.com/reh3376/homebrew-mdemg/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/reh3376/homebrew-mdemg/compare/v0.3.4...v0.4.0
[0.3.4]: https://github.com/reh3376/homebrew-mdemg/compare/v0.3.0...v0.3.4
[0.3.0]: https://github.com/reh3376/homebrew-mdemg/compare/v0.2.15...v0.3.0
[0.2.15]: https://github.com/reh3376/homebrew-mdemg/compare/v0.2.0...v0.2.15
[0.2.0]: https://github.com/reh3376/homebrew-mdemg/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/reh3376/homebrew-mdemg/releases/tag/v0.1.0
