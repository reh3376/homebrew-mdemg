# MDEMG macOS Beta Testing Guide

**Version under test:** v0.4.0 (CLI)
**Date:** _______________
**Tester:** _______________
**Machine specs:** _______________
**macOS version:** _______________
**Docker Desktop version:** _______________

---

## Results Summary

| Tier | Section | Tests | Pass | Fail | Skip | Notes |
|------|---------|-------|------|------|------|-------|
| 1 | Installation & Core | 10 | | | | |
| 2 | Ingestion | 10 | | | | |
| 3 | CMS & RSIC | 10 | | | | |
| 4 | Backup & Maintenance | 5 | | | | |
| 5 | Advanced | 10 | | | | |
| DC | Docker Compose & New Commands | 8 | | | | |
| M | Menubar App (archived — skip) | 6 | | | | |
| **Total** | | **59** | | | | |

---

## Prerequisites

Complete each section below in order before starting the tests. Do not assume anything is pre-installed — verify each item.

### Step 1: Verify macOS Version

MDEMG requires macOS 12 (Monterey) or later on Apple Silicon (M1+) or Intel.

```bash
# Check your macOS version
sw_vers
# ProductVersion must be 12.0 or higher
```

- [ ] macOS version verified: _______________

### Step 2: Install Homebrew

Homebrew is the package manager used to install MDEMG.

```bash
# Check if Homebrew is installed
brew --version

# If "command not found", install Homebrew:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# After install, follow on-screen instructions to add brew to PATH, then verify:
brew --version
```

- [ ] Homebrew installed, version: _______________

### Step 3: Install Docker Desktop

Docker Desktop runs the MDEMG stack (Neo4j, TimescaleDB, MDEMG server, neural sidecar, and Grafana). MDEMG cannot function without it.

```bash
# Check if Docker is already installed and running
docker --version
docker info   # This must succeed — if it errors, Docker Desktop is not running

# Install Docker Desktop — choose one method:

# Method A — Homebrew (recommended):
brew install --cask docker

# Method B — direct download:
# Download from: https://www.docker.com/products/docker-desktop/
# Open the .dmg, drag Docker.app to /Applications
```

After installation:
1. Launch Docker Desktop from `/Applications/Docker.app`
2. Wait for the Docker icon in the menu bar to show "Docker Desktop is running"
3. Accept the license agreement if prompted

```bash
# Verify Docker is running
docker info
# Should show "Server: Docker Desktop"

docker run --rm hello-world
# Should print "Hello from Docker!"
```

> **Note:** Docker Desktop must be running whenever you use MDEMG. It does not auto-start by default. To enable: Docker Desktop menu bar icon > Settings > General > "Start Docker Desktop when you sign in to your computer."

- [ ] Docker Desktop installed and running, version: _______________

### Step 4: Internet Access

The machine must have internet access to:
- Download the MDEMG binary via Homebrew
- Pull Docker images (~2 GB total) on first `mdemg init`
- (Optional) Connect to the OpenAI API for embeddings

```bash
# Verify connectivity to GitHub
curl -s https://api.github.com/repos/reh3376/mdemg/releases/latest | grep tag_name
```

- [ ] Internet access confirmed

### Optional Prerequisites

These are not required for basic testing but are needed for specific test tiers.

#### OpenAI API Key (Tier 2-3: recall, consolidation, memory retrieval)

Required for embedding-powered features: semantic recall, consolidation concept naming, memory retrieval, and SME consulting. Without a key, these features run in degraded mode (stub embeddings or no results).

1. Sign up at [platform.openai.com](https://platform.openai.com)
2. Create an API key at [platform.openai.com/api-keys](https://platform.openai.com/api-keys)
3. Save the key — you'll configure it during `mdemg init` or set it in a `.env` file

- [ ] OpenAI API key obtained (or will skip embedding tests)

#### Ollama (Alternative to OpenAI)

Local-only alternative to OpenAI for embeddings. No API key or internet required after initial download.

```bash
# Install via Homebrew
brew install ollama

# Or download from: https://ollama.com/download/mac

# Pull the recommended embedding model (3072 dims via MRL truncation)
ollama pull qwen3-embedding:8b

# Verify
ollama list
```

> **Dimension note:** MDEMG requires 3072-dimension embeddings. OpenAI `text-embedding-3-large` produces 3072 natively. For Ollama, use `qwen3-embedding:8b` (4096 native, automatically truncated to 3072). Run `mdemg embeddings check` after setup to verify.

- [ ] Ollama installed (or using OpenAI, or will skip embedding tests)

#### Git (Tier 2: hooks, incremental ingest, test project setup)

Required for git hooks, incremental ingest (`--since`), and setting up the test project. Most macOS systems have Git pre-installed via Xcode Command Line Tools.

```bash
# Check if Git is already installed
git --version

# If "command not found", install Xcode Command Line Tools:
xcode-select --install
```

- [ ] Git installed, version: _______________
- [ ] **SKIP** — will skip git-dependent tests (T2.4, T2.5)

### Set Up Test Project

> **Requires:** Git (from optional prerequisites above). If Git is not installed, you can still test most features — just create the test directory and file manually without the git commands.

**With Git installed:**

```bash
mkdir -p ~/mdemg-test && cd ~/mdemg-test
git init
git config user.email "tester@example.com"
git config user.name "Beta Tester"

# Create a sample file for ingestion tests
cat > main.go << 'EOF'
package main

import "fmt"

func main() {
    fmt.Println("Hello from MDEMG beta test")
}
EOF

git add . && git commit -m "initial commit"
```

**Without Git (manual alternative):**

```bash
mkdir -p ~/mdemg-test && cd ~/mdemg-test
cat > main.go << 'EOF'
package main

import "fmt"

func main() {
    fmt.Println("Hello from MDEMG beta test")
}
EOF
```

> **Note:** Without Git, you will need to skip tests T2.4 (incremental ingest), T2.5 (hooks), and T1.3's init may not detect a git repo.

- [ ] Test project directory created at `~/mdemg-test`

### Prerequisites Checklist Summary

| # | Requirement | Status | Comments |
|---|-------------|--------|----------|
| 1 | macOS 12 (Monterey) or later | | Required for Docker Desktop. Verify: `sw_vers` → ProductVersion ≥ 12.0 |
| 2 | Homebrew installed | | Package manager for MDEMG install. Verify: `brew --version` returns a version |
| 3 | Docker Desktop installed and running | | Neo4j runs as a Docker container. Verify: `docker info` succeeds without errors |
| 4 | Internet access confirmed | | Needed to download Homebrew formula and Docker images. Verify: `curl -s https://github.com` returns HTML |
| — | *OpenAI API key (optional)* | | Enables LLM summaries, recall re-ranking, consolidation naming. Without it, those features return degraded results. Verify: `echo $OPENAI_API_KEY` is set |
| — | *Ollama (optional)* | | Local LLM alternative to OpenAI — no API key needed. Verify: `ollama list` shows available models |
| — | *Git (optional)* | | Required for incremental ingest, git hooks, and commit-triggered ingestion. Verify: `git --version` |
| — | Test project created | | Isolated directory for beta testing. Verify: `test -d ~/mdemg-test && echo OK` |

---

## Reference Documentation

These docs cover everything you're testing. Use them for troubleshooting, understanding expected behavior, or exploring beyond the test plan.

| Guide | What it covers |
|-------|---------------|
| [README](README.md) | Quick start, commands overview, configuration, troubleshooting |
| [CLI Reference](docs/cli-reference.md) | All commands, flags, defaults, examples, environment variables |
| [API Reference](docs/api-reference.md) | Every HTTP endpoint with request/response shapes and curl examples |
| [CMS & RSIC Guide](docs/cms-rsic-guide.md) | Conversation memory, Jiminy inner-voice guidance, observation types, self-improvement cycles |
| [Ingestion Guide](docs/ingestion-guide.md) | All 8 ingestion methods — codebase, scraper, Linear, webhooks, file watcher, API |

---

## Tier 1: Installation & Core (~30 min)

### T1.1: Installation

```bash
brew tap reh3376/mdemg
brew install mdemg
```

**Expected:** Homebrew downloads and installs the `mdemg` binary. No errors.

```bash
# Verify binary is on PATH
which mdemg
```

If `mdemg: command not found`, close and reopen your terminal. If it still fails:

```bash
# Check that Homebrew's bin is on PATH
echo $PATH | tr ':' '\n' | grep -i brew
# Should include /opt/homebrew/bin (Apple Silicon) or /usr/local/bin (Intel)

# Fix for Apple Silicon:
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile
```

- [ ] **PASS** — installation completed, `mdemg` accessible from terminal
- [ ] **Method used:** Homebrew

---

### T1.2: Verify Binary

```bash
mdemg version
```

**Expected output:**

```
mdemg v0.4.x
  commit:  <short-hash>
  built:   <date>
  go:      go1.24.x
  os/arch: darwin/arm64    # or darwin/amd64 on Intel
```

- [ ] **PASS** — version displayed with `darwin/arm64` or `darwin/amd64`

---

### T1.3: Initialize Project

```bash
cd ~/mdemg-test
mdemg init
```

**Expected:** Interactive wizard performs the following steps:
1. Checks Docker availability
2. Prompts for Space ID, Neo4j URI and credentials
3. Scans for free ports (MDEMG, Neo4j Bolt/HTTP, TimescaleDB, Neural sidecar, Grafana)
4. Prompts for Grafana and TimescaleDB passwords
5. Prompts for embedding provider (OpenAI/Ollama/disabled) and API key
6. Prompts for LLM summary model selection
7. Prompts for Jiminy inner-voice guidance model
8. Prompts for UxTS plugin enablement
9. Prompts for Git hooks and MCP/IDE integration (Cursor, VS Code, Claude Code)
10. Generates `.env`, `.mdemg/config.yaml`, and `.mdemgignore`
11. Runs `docker compose up -d` to start 5 services (Neo4j, TimescaleDB, MDEMG server, neural sidecar, Grafana)
12. Copies binary to `./bin/mdemg`

> **Important:** Do NOT use `--defaults` here. The interactive wizard lets you enter your OpenAI API key, which is required for embedding and LLM features in subsequent tests.

```bash
# Verify files and services
ls -la .mdemg/config.yaml .mdemgignore .env
docker compose ps    # All 5 services should show "running"
```

- [ ] **PASS** — config files exist, 5 Docker services running

---

### T1.4: Docker Compose Lifecycle

```bash
# Check all services
docker compose ps

# Restart all services
docker compose restart

# Stop all services
docker compose down

# Start all services again
docker compose up -d
```

**Expected:** Each command succeeds. `docker compose ps` shows 5 services (neo4j, timescaledb, mdemg, neural, grafana) as "running".

```bash
# Verify Neo4j specifically
mdemg db status
```

> **Note:** `mdemg db start` and `mdemg db stop` are deprecated. Use `docker compose up -d` / `docker compose down` instead. The legacy commands still work for native/dev mode.

- [ ] **PASS** — all 5 services start, stop, and restart cleanly

---

### T1.5: Database Migrations

```bash
mdemg db migrate
```

**Expected:** Migrations apply without errors. Output shows "applied N migrations" or "already up to date."

- [ ] **PASS** — migrations complete successfully

---

### T1.6: Server Start

> **Note:** In Docker Compose mode (the default after `mdemg init`), the MDEMG server starts automatically as part of `docker compose up -d`. This test verifies the server is running and accessible.

```bash
# Verify server is running (started by Docker Compose)
mdemg status
curl -s http://localhost:9999/healthz | python3 -m json.tool
```

**Expected:** Server is running on port 9999. Healthz returns `{"status":"ok","version":"...","commit":"..."}`.

**If server is not running (native/dev mode only):**

```bash
# Daemon mode
mdemg start --auto-migrate

# Or foreground mode (second terminal)
mdemg serve --auto-migrate
```

- [ ] **PASS** — server running and healthz responds with OK status

---

### T1.7: Health Checks

```bash
# Health check
curl -s http://localhost:9999/healthz

# Readiness check
curl -s http://localhost:9999/readyz
```

**Expected:** Both return `{"status":"ok"}` (or similar JSON with healthy status).

- [ ] **PASS** — both endpoints respond with OK status

---

### T1.8: Configuration Display & Validation

```bash
mdemg config show
mdemg config validate
```

**Expected:** `config show` displays effective configuration with source annotations (yaml/env/default). `config validate` probes Neo4j connectivity and reports results.

- [ ] **PASS** — config show displays settings, validate confirms Neo4j reachable

---

### T1.9: Embedding Provider Check

```bash
mdemg embeddings check
```

**Expected (with OpenAI key configured):** Reports embedding provider, model, and dimension count (3072 for text-embedding-3-large).

**Expected (without key):** Reports "no embedding provider configured" or similar warning. This is acceptable — skip to Tier 2.

- [ ] **PASS** — embedding check runs and reports status
- [ ] **SKIP** — no embedding provider configured (note in results)

---

### T1.10: Browser Dashboard

```bash
open http://localhost:9999/ui/
```

**Expected:** Dashboard loads in the browser with 9 tabs: Status, Memory, Learning, Config, Logs, RSIC, Plugins, Features, Backups. Verify at least 3 tabs render data or a reasonable empty state.

- [ ] **PASS** — browser dashboard loads, tabs are navigable

---

## Tier 2: Ingestion (~20 min)

> **Reference:** [Ingestion Guide](docs/ingestion-guide.md) covers all 8 ingestion methods in detail. [API Reference](docs/api-reference.md#codebase-ingestion-api) has full endpoint documentation.

### T2.1: Codebase Ingestion (CLI)

```bash
mdemg ingest --path . --space-id beta-test
```

**Expected:** Ingests files from the test project. Output shows files processed, observations created.

- [ ] **PASS** — ingest completes, shows file count and observations

---

### T2.2: Single Observation (API)

```bash
curl -s -X POST http://localhost:9999/v1/conversation/observe \
  -H "Content-Type: application/json" \
  -d '{
    "space_id": "beta-test",
    "session_id": "beta-session",
    "content": "This is a test observation from macOS beta testing",
    "obs_type": "learning"
  }'
```

**Expected:** Returns JSON with `node_id` and `status` fields.

- [ ] **PASS** — observation created, node_id returned

---

### T2.3: Batch Ingest (API)

```bash
curl -s -X POST http://localhost:9999/v1/memory/ingest/batch \
  -H "Content-Type: application/json" \
  -d '{
    "space_id": "beta-test",
    "observations": [
      {"content": "macOS batch test item 1", "obs_type": "learning", "session_id": "beta-session"},
      {"content": "macOS batch test item 2", "obs_type": "learning", "session_id": "beta-session"}
    ]
  }'
```

**Expected:** Returns JSON with count of ingested nodes.

- [ ] **PASS** — batch ingest returns success with node count

---

### T2.4: Incremental Ingest

```bash
# Modify test file
echo "// Updated for incremental test" >> main.go
git add . && git commit -m "incremental test change"

# Incremental ingest
mdemg ingest --path . --space-id beta-test --incremental --since HEAD~1
```

**Expected:** Only the modified file is re-ingested.

- [ ] **PASS** — incremental ingest processes only changed files

---

### T2.5: Git Hooks

```bash
# Install hooks
mdemg hooks install --space-id beta-test

# Verify
mdemg hooks list

# Make a commit — hook should trigger auto-ingest
echo "// Hook trigger test" >> main.go
git add . && git commit -m "hook test"
```

**Expected:** `hooks list` shows post-commit hook installed. After commit, hook triggers background ingest (check server logs for ingest activity).

- [ ] **PASS** — hooks install, list shows installed, commit triggers ingest
- [ ] **SKIP** — Git not installed

---

### T2.6: File Watcher

Open a **second terminal:**

```bash
cd ~/mdemg-test
mdemg watch --path . --space-id beta-test
```

In the **original terminal**, create a new file:

```bash
echo "// New file for watcher test" > watcher_test.go
```

**Expected:** The watcher terminal shows the new file was detected and ingested.

Press `Ctrl+C` in the watcher terminal when done.

- [ ] **PASS** — watcher detects file creation and ingests it

---

### T2.7: Web Scraper

> **Skip** if no target URL is available for scraping.

```bash
curl -s -X POST http://localhost:9999/v1/scraper/jobs \
  -H "Content-Type: application/json" \
  -d '{
    "space_id": "beta-test",
    "url": "https://example.com",
    "max_pages": 1
  }'
```

**Expected:** Returns a job ID. Check status with `GET /v1/scraper/jobs/{job_id}`.

- [ ] **PASS** — scraper job created
- [ ] **SKIP** — no URL configured

---

### T2.8: Linear Integration

> **Skip** if no `LINEAR_API_KEY` is configured.

```bash
curl -s http://localhost:9999/v1/linear/issues?space_id=beta-test
```

**Expected:** Returns issues list or empty array.

- [ ] **PASS** — Linear endpoint responds
- [ ] **SKIP** — no LINEAR_API_KEY configured

---

### T2.9: Speed Presets

**T2.9.1: Fast Preset Dry-Run**
```bash
mdemg ingest --path . --speed fast --dry-run
```
Expected: Workers=8, batch=250, LLM summaries disabled, symbol extraction disabled.

**T2.9.2: Thorough Preset Dry-Run**
```bash
mdemg ingest --path . --speed thorough --dry-run
```
Expected: Workers=8, batch=200, LLM summaries enabled, batch=20, symbols enabled.

**T2.9.3: Flag Override**
```bash
mdemg ingest --path . --speed fast --llm-summary=true --dry-run
```
Expected: Fast settings BUT LLM summaries still enabled (flag override takes precedence).

**T2.9.4: Combined Presets**
```bash
mdemg ingest --path . --speed fast --preset ml_cuda --dry-run
```
Expected: Speed preset (workers, batch, LLM) + exclusion preset (ml_cuda dirs/patterns) both applied.

- [ ] **PASS** — all 4 speed/preset combinations show correct dry-run output

---

### T2.10: Claude MD Ingestion

```bash
mdemg ingest-claude-md --space-id beta-test
```

**Expected:** Discovers and ingests Claude Code `.md` files (CLAUDE.md, MEMORY.md, etc.) from known locations. Uses SHA256 content-hash change detection to avoid re-ingesting unchanged files.

- [ ] **PASS** — ingest-claude-md runs and reports files processed
- [ ] **SKIP** — no Claude Code .md files present

---

## Tier 3: CMS & RSIC (~20 min)

> **Reference:** [CMS & RSIC Guide](docs/cms-rsic-guide.md) explains the full CMS workflow, RSIC pipeline, Jiminy inner-voice guidance, and includes practical examples. [API Reference](docs/api-reference.md#conversation-memory) has all endpoint shapes.

### T3.1: Observe (Multiple Types)

```bash
# Decision observation
curl -s -X POST http://localhost:9999/v1/conversation/observe \
  -H "Content-Type: application/json" \
  -d '{
    "space_id": "beta-test",
    "session_id": "beta-session",
    "content": "Decided to use Homebrew for all macOS installations",
    "obs_type": "decision"
  }'

# Error observation
curl -s -X POST http://localhost:9999/v1/conversation/observe \
  -H "Content-Type: application/json" \
  -d '{
    "space_id": "beta-test",
    "session_id": "beta-session",
    "content": "Build failed: missing dependency xyz",
    "obs_type": "error"
  }'
```

**Expected:** Both return JSON with `node_id`.

- [ ] **PASS** — multiple obs_types accepted (decision, error)

---

### T3.2: Resume Session

```bash
curl -s -X POST http://localhost:9999/v1/conversation/resume \
  -H "Content-Type: application/json" \
  -d '{
    "space_id": "beta-test",
    "session_id": "beta-session",
    "max_observations": 10
  }'
```

**Expected:** Returns previously observed content from the session.

- [ ] **PASS** — resume returns prior observations

---

### T3.3: Recall (Semantic Query)

> **Requires:** Embedding provider configured (OpenAI or Ollama)

```bash
curl -s -X POST http://localhost:9999/v1/conversation/recall \
  -H "Content-Type: application/json" \
  -d '{
    "space_id": "beta-test",
    "query": "What decisions were made during testing?",
    "top_k": 5
  }'
```

**Expected:** Returns relevant observations ranked by semantic similarity.

- [ ] **PASS** — recall returns relevant results
- [ ] **SKIP** — no embedding provider (degraded mode)

---

### T3.4: Correct

```bash
curl -s -X POST http://localhost:9999/v1/conversation/correct \
  -H "Content-Type: application/json" \
  -d '{
    "space_id": "beta-test",
    "session_id": "beta-session",
    "incorrect": "dependency xyz is version 1.0",
    "correct": "dependency xyz is actually version 2.0"
  }'
```

**Expected:** Returns JSON confirming the correction was recorded.

- [ ] **PASS** — correction accepted and stored

---

### T3.5: Consolidation

```bash
curl -s -X POST http://localhost:9999/v1/memory/consolidate \
  -H "Content-Type: application/json" \
  -d '{"space_id": "beta-test"}'
```

**Expected:** Returns consolidation results (hidden nodes created, edges formed). Without an LLM key, concept naming may be degraded but consolidation still runs.

- [ ] **PASS** — consolidation completes

---

### T3.6: Session Health

```bash
curl -s "http://localhost:9999/v1/conversation/session/health?space_id=beta-test&session_id=beta-session"
```

**Expected:** Returns health metrics for the session (observation count, freshness, etc.).

- [ ] **PASS** — session health returned with metrics

---

### T3.7: RSIC Assess

```bash
curl -s -X POST http://localhost:9999/v1/self-improve/assess \
  -H "Content-Type: application/json" \
  -d '{"space_id": "beta-test"}'
```

**Expected:** Returns assessment with scores and recommendations.

- [ ] **PASS** — assessment returned

---

### T3.8: RSIC Cycle (Dry Run)

```bash
curl -s -X POST http://localhost:9999/v1/self-improve/cycle \
  -H "Content-Type: application/json" \
  -d '{"space_id": "beta-test", "dry_run": true}'
```

**Expected:** Returns what the self-improvement cycle *would* do, without making changes.

- [ ] **PASS** — dry run cycle returns plan

---

### T3.9: RSIC Health

```bash
curl -s "http://localhost:9999/v1/self-improve/health?space_id=beta-test"
```

**Expected:** Returns RSIC health metrics.

- [ ] **PASS** — RSIC health returned

---

### T3.10: Learning Freeze / Unfreeze

```bash
# Freeze
curl -s -X POST http://localhost:9999/v1/learning/freeze \
  -H "Content-Type: application/json" \
  -d '{"space_id": "beta-test", "reason": "beta testing", "frozen_by": "tester"}'

# Check status
curl -s "http://localhost:9999/v1/learning/freeze/status?space_id=beta-test"

# Unfreeze
curl -s -X POST http://localhost:9999/v1/learning/unfreeze \
  -H "Content-Type: application/json" \
  -d '{"space_id": "beta-test"}'
```

**Expected:** Freeze returns confirmation, status shows frozen=true, unfreeze returns confirmation.

- [ ] **PASS** — freeze/status/unfreeze cycle completes

---

## Tier 4: Backup & Maintenance (~10 min)

### T4.1: Backup Trigger

```bash
curl -s -X POST http://localhost:9999/v1/backup/trigger \
  -H "Content-Type: application/json" \
  -d '{"type": "full", "space_ids": ["beta-test"]}'
```

**Expected:** Returns backup job ID or confirmation.

- [ ] **PASS** — backup triggered

---

### T4.2: Backup List

```bash
curl -s "http://localhost:9999/v1/backup/list?space_id=beta-test"
```

**Expected:** Returns list of backups (may include the one just created).

- [ ] **PASS** — backup list returned

---

### T4.3: Decay (Dry Run)

```bash
mdemg decay --space-id beta-test --dry-run
```

**Expected:** Shows what edges would be decayed without making changes.

- [ ] **PASS** — decay dry run shows results

---

### T4.4: Prune (Dry Run)

```bash
mdemg prune --space-id beta-test --dry-run
```

**Expected:** Shows what edges/nodes would be pruned without making changes.

- [ ] **PASS** — prune dry run shows results

---

### T4.5: Space List

```bash
mdemg space list
```

**Expected:** Lists all spaces including `beta-test`.

- [ ] **PASS** — space list shows beta-test

---

## Tier 5: Advanced (~15 min)

> **Reference:** [CLI Reference](docs/cli-reference.md) has full flag details for every command. [API Reference](docs/api-reference.md#mcp-server-tools) covers MCP server tools.

### T5.1: Secrets (macOS Keychain)

```bash
# Store a test secret
mdemg config set-secret TEST_BETA_KEY "beta-test-value-12345"

# Retrieve it
mdemg config get-secret TEST_BETA_KEY

# List all secrets
mdemg config list-secrets
```

**Expected:** Secret is stored in the macOS system keychain (via Keychain Access.app), retrieved correctly, and listed.

- [ ] **PASS** — set/get/list secrets works via macOS keychain

---

### T5.2: Memory Retrieval

```bash
curl -s -X POST http://localhost:9999/v1/memory/retrieve \
  -H "Content-Type: application/json" \
  -d '{
    "space_id": "beta-test",
    "query_text": "beta testing",
    "top_k": 5
  }'
```

**Expected:** Returns retrieved memory nodes.

- [ ] **PASS** — memory retrieval returns results
- [ ] **SKIP** — no embedding provider

---

### T5.3: Demo

```bash
mdemg demo
```

**Expected:** Interactive demo runs, shows MDEMG capabilities. Follow on-screen prompts.

- [ ] **PASS** — demo runs to completion

---

### T5.4: Extract Symbols

```bash
mdemg extract-symbols --path .
```

**Expected:** Extracts code symbols (functions, types, etc.) from files in the directory.

- [ ] **PASS** — symbols extracted and listed

---

### T5.5: Consolidation (CLI)

```bash
mdemg consolidate --space-id beta-test --hidden-layer --dry-run
```

**Expected:** Shows consolidation plan without executing.

- [ ] **PASS** — consolidation dry run shows plan

---

### T5.6: MCP Server

```bash
mdemg mcp
```

**Expected:** MCP server starts and listens for JSON-RPC input on stdin. Press `Ctrl+C` to exit.

- [ ] **PASS** — MCP server starts, responds to Ctrl+C

---

### T5.7: Upgrade Check

```bash
# Check for stable updates
mdemg upgrade --dry-run

# Check for edge updates (latest main branch build)
mdemg upgrade --edge --dry-run
```

**Expected:** Reports current version, latest available version, and whether an update is available. The `--edge` variant checks against the rolling edge release (updated on every merge to main).

> **Note:** `mdemg update` is an alias for `mdemg upgrade`.

- [ ] **PASS** — stable upgrade check runs and reports version information
- [ ] **PASS** — edge upgrade check runs and reports commit information
- [ ] **FAIL** — upgrade fails (note error message below)

**Error message received (if failed):** _______________

---

### T5.8: Space Export/Import (API)

```bash
# Preview what would be exported
curl -s "http://localhost:9999/v1/admin/spaces/export/preview?space_id=beta-test&profile=full"

# Export the space
curl -s -X POST http://localhost:9999/v1/admin/spaces/export \
  -H "Content-Type: application/json" \
  -d '{"space_id":"beta-test","profile":"metadata"}' > /tmp/beta-export.json

# Verify export has chunks
cat /tmp/beta-export.json | jq '.summary'

# Import to a new space (empty chunks for validation)
curl -s -X POST http://localhost:9999/v1/admin/spaces/import \
  -H "Content-Type: application/json" \
  -d '{"space_id":"beta-test-import","conflict":"skip","chunks":[]}'
```

**Expected:**
- Preview returns `estimated_nodes`, `profile`, and `filters_applied`
- Export returns JSON with `header.format: "mdemg-space-transfer"`, `chunks` array, and `summary`
- Import returns `nodes_created: 0` (empty chunks), `warnings: []`

```bash
# CLI export/import (alternative)
mdemg space export --space-id beta-test --output /tmp/beta-test.mdemg --profile metadata
mdemg space import --input /tmp/beta-test.mdemg --target-space beta-test-cli-import
```

- [ ] **PASS** — API export preview returns valid JSON with estimated counts
- [ ] **PASS** — API export returns chunks with `mdemg-space-transfer` format
- [ ] **PASS** — API import accepts empty chunks and returns 200
- [ ] **PASS** — CLI export creates `.mdemg` file
- [ ] **PASS** — CLI import succeeds with target space

---

### T5.9: Teardown Dry Run (CLI)

```bash
cd ~/mdemg-test
mdemg teardown --dry-run
```

**Expected:** Lists all artifacts that would be removed (server, Docker container/volume, hooks, MCP configs, `.mdemg/` directory, sidebar registration) without making any changes.

- [ ] **PASS** — dry run lists artifacts without making changes

---

### T5.10: Teardown (CLI)

> **Warning:** This removes all MDEMG artifacts for the test project. Run this test LAST — it replaces the manual cleanup steps below.

```bash
cd ~/mdemg-test

# Preview what would be removed
mdemg teardown --dry-run

# Execute teardown (stops services, removes hooks, cleans config)
mdemg teardown --yes
```

**Expected:** Dry run lists all artifacts that would be removed. Full teardown stops the server, removes Docker containers/volumes, uninstalls hooks, cleans MCP/IDE configs, and removes `.mdemg/`.

```bash
# Verify cleanup
ls .mdemg 2>/dev/null && echo "FAIL: .mdemg still exists" || echo "OK: .mdemg removed"
mdemg hooks list 2>/dev/null || echo "OK: hooks check (expected to fail — no .mdemg)"
```

- [ ] **PASS** — dry run lists artifacts, teardown removes all MDEMG artifacts

---

## Tier DC: Docker Compose & New Commands (~15 min)

> **Requires:** All services running via `docker compose up -d` (completed during `mdemg init`).

### DC.1: Docker Compose Status

```bash
docker compose ps
```

**Expected:** 5 services listed as "running": neo4j, timescaledb, mdemg, neural, grafana.

- [ ] **PASS** — all 5 services running

---

### DC.2: TimescaleDB Commands

```bash
mdemg tsdb status
mdemg tsdb stats
```

**Expected:** `tsdb status` shows connection status. `tsdb stats` shows metric counts and table sizes.

- [ ] **PASS** — both commands return data without errors

---

### DC.3: Sidecar Commands

```bash
mdemg sidecar status
mdemg sidecar doctor
```

**Expected:** `sidecar status` shows sidecar service state. `sidecar doctor` runs health checks and reports results.

- [ ] **PASS** — both commands return status information

---

### DC.4: Synergy Commands

```bash
mdemg synergy status
```

**Expected:** Reports synergy fingerprint, version alignment, and optimization suggestions.

- [ ] **PASS** — synergy status returns without errors

---

### DC.5: Data Commands

```bash
mdemg data status
mdemg data audit
```

**Expected:** `data status` shows training data collection state. `data audit` reports data quality metrics.

- [ ] **PASS** — both commands return data or "no data collected yet"

---

### DC.6: Service Supervision

```bash
mdemg service status
```

**Expected:** Reports OS-level service status (installed/not installed, running/stopped).

- [ ] **PASS** — service status returns without errors

---

### DC.7: Grafana Access

```bash
curl -s http://localhost:3000/api/health
```

**Expected:** Grafana responds with `{"database":"ok"}` or similar healthy status.

- [ ] **PASS** — Grafana health endpoint responds

---

### DC.8: Browser Dashboard Tabs

Navigate to `http://localhost:9999/ui/` and click through each of the 9 tabs:

| Tab | What to look for |
|-----|-----------------|
| **Status** | Server status, subsystem health, configured models |
| **Memory** | Observation count, layer breakdown (L0-L5), health score |
| **Learning** | Hebbian edge count, learning phase, Freeze/Unfreeze toggle |
| **Config** | Key-value config pairs with source annotations |
| **Logs** | Recent server logs, search/filter, color-coded severity |
| **RSIC** | Engine status, watchdog health, cycle history |
| **Plugins** | Installed plugins with status badges |
| **Features** | Feature toggles and status |
| **Backups** | Backup history, trigger backup button |

- [ ] **PASS** — all 9 tabs load and display data (or reasonable empty state)

---

## Tier M: Menubar App (~15 min) — ARCHIVED

> **The mdemg-menubar repository has been archived.** The Browser Dashboard at `http://localhost:9999/ui/` replaces the menubar app for status monitoring and configuration. This tier is preserved for historical reference but **should be skipped** during testing. See Tier DC for the browser dashboard tests instead.

> **Requires:** The MDEMG server must be running (`mdemg status` shows healthy). Run these tests **before** T5.10 (teardown), which removes the instance the menubar monitors.

### M.1: Install Menubar App

```bash
# Download the latest .app.zip
curl -fsSL -o /tmp/MdemgMenuBar.app.zip \
  "https://github.com/reh3376/mdemg-menubar/releases/latest/download/MdemgMenuBar.app.zip"

# Extract
cd /tmp && unzip -o MdemgMenuBar.app.zip

# Move to Applications
mv /tmp/MdemgMenuBar.app /Applications/

# Remove quarantine attribute (required for unsigned apps)
xattr -rd com.apple.quarantine /Applications/MdemgMenuBar.app

# Launch
open /Applications/MdemgMenuBar.app
```

> **macOS Security Warning:** On first launch, macOS may block the app with "MdemgMenuBar cannot be opened because it is from an unidentified developer." If this happens:
> 1. Open **System Settings** → **Privacy & Security**
> 2. Scroll down to the security section — you should see "MdemgMenuBar was blocked"
> 3. Click **"Open Anyway"** → confirm the dialog
> 4. The app should now launch and appear in the menu bar

**Expected:** A small icon appears in the macOS menu bar (top-right area, near the clock).

- [ ] **PASS** — menubar app installed and icon visible in menu bar
- [ ] **Method used:** GitHub release download

---

### M.2: Menubar Connection

Click the menubar icon to open the popover window.

**Expected:** The popover opens showing:
- Instance name in the header (e.g., "mdemg-test" or "MDEMG")
- A **"Running"** status badge with a green dot (top-right of header)
- A gear icon for Preferences (top-right)
- 7 tabs: Status, Memory, Learning, Neo4j, Config, Logs, RSIC

If the status badge shows **"Stopped"** (red dot), verify the server is running:

```bash
curl -s http://localhost:9999/healthz
```

- [ ] **PASS** — popover opens, shows "Running" badge, 7 tabs visible

---

### M.3: Browse All Tabs

Click through each tab and verify it loads data (not just a blank view):

| Tab | What to look for |
|-----|-----------------|
| **Status** | Server status (Running/Stopped), subsystem health indicators (embeddings, Neo4j, LLM), configured models, active services |
| **Memory** | Total observation count, layer breakdown (L0-L5), memory health score, Knowledge Sharing section (Export/Import buttons with profile and space pickers) |
| **Learning** | Hebbian edge count, learning phase (cold/learning/warm/saturated), Freeze/Unfreeze toggle, Prune button |
| **Neo4j** | Database version, total node/relationship counts, connection pool stats, container status (Running/Stopped), lifecycle buttons (Start/Stop), resource usage |
| **Config** | Server endpoint, space ID, PID file path, key-value config pairs, Backup section (trigger + list), Migrate button, **Instance Removal** section ("Remove Instance..." button) |
| **Logs** | Recent server log lines, search/filter field, color-coded severity levels, refresh button |
| **RSIC** | Engine status (idle/running), watchdog health, recent cycle history, calibration confidence scores |

> **Tip:** Some tabs (Memory, Learning, RSIC) populate with more data after you've run ingestion and observation tests in Tiers 2-3. If a tab shows mostly zeros or "—", that's expected on a fresh install.

- [ ] **PASS** — all 7 tabs load and display data (or reasonable empty state)

---

### M.4: Test Server Controls

From the **Status** tab, test the server lifecycle controls:

1. **Stop the server** using the Status tab's stop button
2. Verify the status badge changes to **"Stopped"** with a red dot
3. **Start the server** using the Status tab's start button
4. Wait ~10 seconds for the health poll to update
5. Verify the status badge changes back to **"Running"** with a green dot

> **Note:** The menubar polls the server on a configurable interval (default: 10s for health, 30s for stats). After clicking Start, the badge may take up to 10 seconds to update. If the badge doesn't update, close and reopen the popover.

**Fallback:** If the start button doesn't work, start the server from the terminal:

```bash
mdemg start --auto-migrate
```

- [ ] **PASS** — stop/start cycle works, status badge updates correctly

---

### M.5: Instance Manager

1. Click the **gear icon** (top-right of header) → Preferences popover opens
2. In the **Instances** section, click **"Manage Instances..."**
3. Verify the **Instance Manager** sheet opens showing registered instances with status dots, directory paths, and server URLs
4. Click the **"+"** button → **Add Instance** sheet opens
5. Enter a test instance: Name = `test-instance`, Directory = `/tmp`, Space ID = `mdemg-dev`
6. Click **Add** → verify the new instance appears in the list
7. **Right-click** the test instance → verify context menu shows "Remove from List" and "Remove Instance..."
8. Click **"Remove from List"** → verify the instance is removed (this only removes it from the menubar, it does NOT run teardown)

- [ ] **PASS** — Instance Manager opens, add/select/remove-from-list works, context menu appears

---

### M.6: Auto-Update Check

1. Click the **gear icon** → Preferences popover opens
2. In the **General** section, note the current version number
3. Click **"Check for Updates"**
4. If an update is available: a blue banner appears at the top of Preferences showing the version transition (e.g., "v1.7.0 → v1.8.0") with an **"Update"** button, and a blue dot appears on the gear icon in the main header

> **Important:** Do **NOT** click the "Update" button during testing — updating replaces the app version being tested, which would invalidate remaining test results. Just verify the update check mechanism works.

**Expected (no update):** The "Check for Updates" button briefly shows a spinner, then returns to normal (no banner).

**Expected (update available):** Blue update banner with version transition and "Update" button.

- [ ] **PASS** — update check completes without error
- [ ] **Update available?** Yes / No (note version if yes: _______________)

---

## Cleanup / Teardown

### Recommended: Use `mdemg teardown` (if T5.10 was not already run)

```bash
cd ~/mdemg-test
mdemg teardown --yes
```

This single command handles steps 1-6 below automatically: stops the server, removes Docker containers/volumes, uninstalls hooks, cleans MCP/IDE configs, backs up and removes `.mdemg/`.

### Manual cleanup (fallback)

If `mdemg teardown` is not available or failed:

```bash
# 1. Stop the server
# If using daemon mode:
mdemg stop
# If using foreground mode: press Ctrl+C in the server terminal

# 2. Uninstall git hooks
cd ~/mdemg-test
mdemg hooks uninstall

# 3. Stop and remove all Docker Compose services and volumes
docker compose down -v

# 5. Remove MDEMG config (optional — only if uninstalling entirely)
# rm -rf .mdemg

# 6. Clean up test secret
mdemg config set-secret TEST_BETA_KEY ""
```

### Final cleanup (all methods)

```bash
# Remove test project
rm -rf ~/mdemg-test
```

---

## Known macOS Limitations

> **See also:** [README — Troubleshooting](README.md#troubleshooting) for common issues and fixes.

### 1. Daemon Mode (`mdemg start/stop/restart`)

> **Note:** Docker Compose is the primary deployment method as of v0.3.0. Daemon mode (`mdemg start/stop/restart`) is for native development only. Most users should use `docker compose up -d` instead.

**Issue:** Daemon mode uses Unix process management (PID files, signal handling). It works natively on macOS but may occasionally fail if the PID file becomes stale (e.g., after a system crash).

**Workaround:** If `mdemg start` reports the server is already running but `mdemg status` shows it's not responding:

```bash
# Remove stale PID file
rm -f .mdemg/mdemg.pid

# Restart
mdemg start --auto-migrate
```

For unattended operation, use `mdemg service install` (recommended) or create a launchd plist manually:

```bash
cat > ~/Library/LaunchAgents/com.mdemg.server.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.mdemg.server</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/bin/mdemg</string>
        <string>serve</string>
        <string>--auto-migrate</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/mdemg-stdout.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/mdemg-stderr.log</string>
</dict>
</plist>
EOF

# Load the service
launchctl load ~/Library/LaunchAgents/com.mdemg.server.plist
```

### 2. Docker Desktop Memory

**Issue:** Docker Desktop defaults to limited memory allocation. The MDEMG stack runs 5 services (Neo4j, TimescaleDB, MDEMG server, neural sidecar, Grafana) which may fail to start or run slowly if Docker doesn't have enough resources.

**Workaround:** Docker Desktop menu bar icon > Settings > Resources: set Memory to at least **4 GB** and CPUs to at least **2**.

### 3. Apple Silicon vs Intel

**Issue:** The Homebrew formula installs the correct architecture automatically (`darwin/arm64` for Apple Silicon, `darwin/amd64` for Intel). Verify with `mdemg version` — the `os/arch` line should match your hardware.

**Workaround:** If the wrong architecture was installed:

```bash
brew reinstall mdemg
mdemg version   # Verify os/arch
```

### 4. Features Requiring an LLM API Key

The following features return degraded or empty results without an OpenAI or Ollama embedding provider configured:

- `recall` — semantic search returns no results
- `consolidation` — concept naming uses fallback (generic names)
- `SME consult` — consulting service unavailable
- `meta-learn` — cross-space generalization unavailable

**Workaround:** Set an OpenAI key in `.env` or via the macOS keychain:

```bash
mdemg config set-secret OPENAI_API_KEY sk-...
# Or in .env:
# OPENAI_API_KEY=sk-...
```

### 5. Web Scraper / Linear Integration

**Issue:** These features require separate API key configuration and external service access.

**Workaround:** Configure in `.env` or via `mdemg config set-secret`:

```bash
# Linear
mdemg config set-secret LINEAR_API_KEY lin_api_...

# Scraper works with public URLs, no key needed
```

### 6. Port Conflicts

**Issue:** If another service is using port 9999, the MDEMG server will fail to start.

**Workaround:** Check what's using the port and either stop it or configure MDEMG to use a different port:

```bash
# Check what's using port 9999
lsof -i :9999

# Start server on a different port
LISTEN_ADDR=:10000 mdemg serve --auto-migrate
```

### 7. Docker Compose Port Conflicts

**Issue:** The MDEMG stack uses several ports by default (9999 for MDEMG server, 7474/7687 for Neo4j, 5432 for TimescaleDB, 3000 for Grafana). If other services are using these ports, `docker compose up -d` may fail.

**Workaround:** `mdemg init` automatically detects port conflicts and assigns free ports. If you encounter conflicts after init:

```bash
# Check which ports are in use
lsof -i :9999 -i :7474 -i :7687 -i :5432 -i :3000

# Edit .env to change conflicting ports, then restart
docker compose down
# Edit LISTEN_ADDR, NEO4J_HTTP_PORT, etc. in .env
docker compose up -d
```

---

## Feedback & Issue Reporting

### Filing Issues

File issues at: **https://github.com/reh3376/mdemg/issues**

**Title format:** `[macOS Beta] <brief description>`

**Labels:** Add `macos` and `beta-testing`

### Include in Every Report

```
**Environment:**
- macOS version: (output of `sw_vers`)
- Architecture: (output of `uname -m` — arm64 or x86_64)
- MDEMG version: (output of `mdemg version`)
- Docker Desktop version: (output of `docker --version`)
- Shell: (output of `echo $SHELL`)
- Installation method: Homebrew

**Steps to Reproduce:**
1. <exact command>
2. <exact command>

**Expected Result:**
<what should have happened>

**Actual Result:**
<what actually happened — paste full output>

**Server Log (if applicable):**
<output of: tail -50 .mdemg/logs/mdemg.log>
```

### Severity Guide

| Severity | Meaning | Example |
|----------|---------|---------|
| **Critical** | Cannot install or start | Binary won't run, server crashes on start |
| **High** | Core feature broken | Ingest fails, observations not stored |
| **Medium** | Feature degraded | Hooks don't fire, config show incomplete |
| **Low** | Cosmetic or edge case | Minor formatting issue, help text typo |

---

## End of Testing

After completing all tiers, fill in the Results Summary table at the top of this document and submit it along with any issues filed.

Thank you for beta testing MDEMG on macOS!
