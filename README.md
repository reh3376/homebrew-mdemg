# homebrew-mdemg

Homebrew tap for [MDEMG](https://github.com/reh3376/mdemg) — Multi-Dimensional Emergent Memory Graph.

MDEMG is a cognitive substrate for AI-assisted development. It gives AI agents persistent, emergent long-term memory where higher-level concepts and relationships arise automatically from accumulated observations through Hebbian learning.

## Install

```bash
brew tap reh3376/mdemg
brew install mdemg
```

## Upgrade

```bash
brew update
brew upgrade mdemg
```

## Verify

```bash
mdemg version
```

## Prerequisites

- **Docker** — required for Neo4j (MDEMG's graph database backend)

## Quick Start

```bash
# Initialize a project
mdemg init

# Start the database and server
mdemg db start
mdemg start --auto-migrate

# Check status
mdemg status

# Ingest a codebase
mdemg ingest .
```

## Links

- [MDEMG Repository](https://github.com/reh3376/mdemg)
- [Releases](https://github.com/reh3376/mdemg/releases)

## How It Works

This tap is updated automatically by [GoReleaser](https://goreleaser.com/) on each tagged release of MDEMG. The formula (`mdemg.rb`) is generated — do not edit it manually.
