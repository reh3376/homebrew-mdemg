# MDEMG — Multi-Dimensional Emergent Memory Graph

Persistent memory for AI agents. Observations accumulate, cluster into themes, and promote to emergent concepts through Hebbian learning — giving LLMs a long-term knowledge graph that grows and self-organizes.

---

## Prerequisites

Complete each item below before installing MDEMG. Verify each one — do not assume anything is already installed.

### 1. macOS Version

MDEMG requires macOS 12 (Monterey) or later on Apple Silicon (M1+) or Intel.

```bash
# Check your macOS version
sw_vers
# ProductVersion must be 12.0 or higher
```

### 2. Homebrew

Homebrew is the package manager used to install MDEMG. If you don't have it, install it first.

```bash
# Check if Homebrew is installed
brew --version
# If "command not found", install Homebrew:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# After install, follow the on-screen instructions to add brew to your PATH
# Then verify:
brew --version
```

### 3. Docker Desktop

Docker Desktop runs the Neo4j database container. MDEMG cannot function without it.

```bash
# Check if Docker is installed and running
docker --version
docker info    # This must succeed — if it errors, Docker Desktop is not running
```

If Docker is not installed:

1. Download from [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/) or install via Homebrew:
   ```bash
   brew install --cask docker
   ```
2. Launch Docker Desktop from `/Applications/Docker.app`
3. Wait for the Docker icon in the menu bar to show "Docker Desktop is running"
4. Accept the license agreement if prompted

```bash
# Verify Docker is running
docker run --rm hello-world
# Should print "Hello from Docker!"
```

> **Note:** Docker Desktop must be running whenever you use MDEMG. It does not auto-start by default. To enable auto-start: Docker Desktop menu bar icon → Settings → General → "Start Docker Desktop when you sign in to your computer."

### 4. OpenAI API Key (recommended) or Ollama

An embedding provider powers semantic search, recall, consolidation naming, and SME consulting. Without one, these features run in degraded mode (no results or generic fallbacks).

**Option A — OpenAI (recommended):**
1. Sign up at [platform.openai.com](https://platform.openai.com)
2. Create an API key at [platform.openai.com/api-keys](https://platform.openai.com/api-keys)
3. You'll configure this key during `mdemg init`, or set it manually:
   ```bash
   echo 'OPENAI_API_KEY=sk-...' >> .env
   ```

**Option B — Ollama (local-only, no API key needed):**
1. Download from [ollama.com/download/mac](https://ollama.com/download/mac) or:
   ```bash
   brew install ollama
   ```
2. Pull an embedding model:
   ```bash
   ollama pull nomic-embed-text
   ```
3. Verify it's running:
   ```bash
   ollama list
   # Should show nomic-embed-text in the list
   ```

**Option C — Skip (degraded mode):**
You can run MDEMG without an embedding provider. Ingestion, observation storage, consolidation structure, and most API endpoints will work. Semantic recall and LLM-powered naming will be unavailable or return empty results.

### 5. Git (optional but recommended)

Required for git hooks, incremental ingest (`--since`), and `mdemg hooks install`. Most macOS systems have Git pre-installed via Xcode Command Line Tools.

```bash
# Check if Git is installed
git --version
# If "command not found", install Xcode Command Line Tools:
xcode-select --install
```

### Prerequisites Checklist

| # | Requirement | How to verify |
|---|-------------|---------------|
| 1 | macOS 12+ | `sw_vers` → ProductVersion ≥ 12.0 |
| 2 | Homebrew installed | `brew --version` returns a version |
| 3 | Docker Desktop installed and running | `docker info` succeeds without errors |
| 4 | OpenAI API key or Ollama (optional) | `echo $OPENAI_API_KEY` is set, or `ollama list` shows models |
| 5 | Git installed (optional) | `git --version` returns a version |

---

## Installation

```bash
brew tap reh3376/mdemg
brew install mdemg
```

**Verify the installation:**

```bash
mdemg version
```

**Expected output:**

```
mdemg v0.2.x
  commit:  <short-hash>
  built:   <date>
  go:      go1.24.x
  os/arch: darwin/arm64    # or darwin/amd64 on Intel
```

If `mdemg: command not found`, close and reopen your terminal, then try again. If it still fails:

```bash
# Check if the binary exists
ls $(brew --prefix)/bin/mdemg

# If it exists but isn't found, ensure Homebrew's bin is on your PATH:
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile
```

---

## Quick Start

### Option A: One command

```bash
export OPENAI_API_KEY=sk-...    # skip if using Ollama or no embedding provider
mdemg init --quick
```

This runs the full setup sequence: creates config, starts Neo4j, starts the server, applies migrations, and confirms readiness.

**Expected output (success):**

```
✓ Config created: .mdemg/config.yaml
✓ Neo4j container started
✓ Migrations applied (v18)
✓ Server started on :9999
✓ Health check passed
```

**Verify everything is running:**

```bash
mdemg status
```

Skip to [Set Up a Test Project](#set-up-a-test-project) below.

### Option B: Step by step

Use this if Option A fails, or if you want to understand each step.

**Step 1 — Initialize configuration:**

```bash
cd ~/your-project    # or any directory you want to use with MDEMG
mdemg init           # Interactive wizard — press Enter to accept defaults
```

Expected: creates `.mdemg/config.yaml` and `.mdemgignore` in the current directory.

```bash
# Verify
ls -la .mdemg/config.yaml .mdemgignore
```

For non-interactive setup with all defaults:

```bash
mdemg init --defaults
```

**Step 2 — Start Neo4j:**

```bash
mdemg db start
```

Expected: starts a Docker container running Neo4j. First run pulls the `neo4j:5` image (~500MB).

```bash
# Verify container is running
mdemg db status
# Should show: container running, bolt port 7687, HTTP port 7474
```

**Step 3 — Start the server:**

```bash
mdemg start --auto-migrate
```

Expected: starts the MDEMG server as a background daemon on port 9999 and applies any pending database migrations.

```bash
# Verify server is running
mdemg status
# Should show server running on :9999, database connected

# Health check
curl -s http://localhost:9999/healthz
# Expected: {"status":"ok"}

# Readiness check
curl -s http://localhost:9999/readyz
# Expected: {"status":"ok"} (or JSON showing component health)
```

If `mdemg start` fails, use foreground mode in a separate terminal window:

```bash
mdemg serve --auto-migrate
# Leave this terminal running — continue in another window
```

**Step 4 — Ingest a codebase:**

```bash
mdemg ingest --path .
```

Expected: scans the directory, extracts code symbols and content, and stores them as observations in the knowledge graph. Output shows files processed and observations created.

---

## Set Up a Test Project

If you are beta testing or trying MDEMG for the first time, create a dedicated test directory:

```bash
mkdir -p ~/mdemg-test && cd ~/mdemg-test
git init
git config user.email "tester@example.com"
git config user.name "Beta Tester"

# Create sample files for ingestion
cat > main.go << 'EOF'
package main

import "fmt"

func main() {
    fmt.Println("Hello from MDEMG beta test")
}
EOF

git add . && git commit -m "initial commit"
```

Then run through the Quick Start steps from within this directory.

---

## Verify Core Functionality

After completing the Quick Start, verify these core features work. Run each command and check the expected output.

### Configuration

```bash
# Display effective config with source annotations (yaml/env/default)
mdemg config show

# Validate config syntax and probe Neo4j/embedding connectivity
mdemg config validate
# Expected: reports Neo4j reachable, embedding provider status
```

### Embedding provider

```bash
mdemg embeddings check
# With OpenAI: reports provider, model (text-embedding-3-large), dimensions (3072)
# With Ollama: reports provider, model, dimensions
# Without provider: reports "no embedding provider configured" — this is OK
```

### Ingest and observe

```bash
# Ingest the test project
mdemg ingest --path . --space-id test

# Create a manual observation via API
curl -s -X POST http://localhost:9999/v1/conversation/observe \
  -H "Content-Type: application/json" \
  -d '{"space_id":"test","session_id":"test-session","content":"Test observation from macOS beta","obs_type":"learning"}'
# Expected: JSON with "node_id" and "status" fields
```

### Recall (requires embedding provider)

```bash
curl -s -X POST http://localhost:9999/v1/conversation/recall \
  -H "Content-Type: application/json" \
  -d '{"space_id":"test","query":"What was tested?","top_k":5}'
# Expected: returns relevant observations ranked by semantic similarity
# Without embedding provider: returns empty or degraded results — this is expected
```

### Resume session

```bash
curl -s -X POST http://localhost:9999/v1/conversation/resume \
  -H "Content-Type: application/json" \
  -d '{"space_id":"test","session_id":"test-session","max_observations":10}'
# Expected: returns previously observed content from the session
```

### Git hooks (optional — requires Git)

```bash
# Install post-commit hook for auto-ingestion
mdemg hooks install --space-id test

# Verify
mdemg hooks list
# Expected: shows post-commit hook installed

# Make a commit — hook triggers background ingest
echo "// hook test" >> main.go
git add . && git commit -m "hook test"
# Check server output or logs for ingest activity
```

### Space management

```bash
mdemg space list
# Expected: lists all spaces including "test"
```

---

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
| `mdemg db stop` | Stop Neo4j container (`--remove` to delete) |
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
| `mdemg config set-secret` | Store a secret in the system keychain |
| `mdemg config get-secret` | Retrieve a secret from the system keychain |
| `mdemg config list-secrets` | List known secrets and their keychain status |
| `mdemg hooks install` | Install git post-commit hooks for auto-ingestion |
| `mdemg hooks uninstall` | Remove installed git hooks |
| `mdemg hooks list` | List installed hooks and their status |
| `mdemg decay` | Apply temporal decay to learning edges |
| `mdemg prune` | Prune weak edges, tombstone orphans |
| `mdemg sidecar` | Manage sidecar services (up, down, attach, detach) |
| `mdemg mcp` | Run MCP server for IDE integration |
| `mdemg space` | Manage memory spaces (list, export, import, copy, delete, rename, info) |
| `mdemg plugin` | Manage plugins |
| `mdemg demo` | Run interactive demo |
| `mdemg upgrade` | Self-update to the latest release |

Use `mdemg <command> --help` for full flag details on any command.

For complete reference documentation, see the [CLI Reference](docs/cli-reference.md).

---

## Documentation

| Guide | What it covers |
|-------|---------------|
| [CLI Reference](docs/cli-reference.md) | All commands, flags, defaults, examples, environment variables |
| [API Reference](docs/api-reference.md) | Every HTTP endpoint with request/response shapes and curl examples |
| [CMS & RSIC Guide](docs/cms-rsic-guide.md) | Conversation memory, observation types, surprise scoring, self-improvement cycles |
| [Ingestion Guide](docs/ingestion-guide.md) | All 8 ingestion methods — codebase, scraper, Linear, webhooks, file watcher, API |

---

## Configuration

Priority chain (lowest to highest):

```
defaults → .mdemg/config.yaml → keychain → .env → environment variables → CLI flags
```

### View and validate

```bash
# View effective config with source annotations
mdemg config show
# Add --json for machine-readable output
mdemg config show --json

# Validate syntax and probe connectivity
mdemg config validate
```

### Config file

Created by `mdemg init` at `.mdemg/config.yaml`. Example:

```yaml
server:
  port: 9999
neo4j:
  uri: bolt://localhost:7687
  user: neo4j
  password: mdemg-dev
embeddings:
  provider: openai           # or "ollama"
  model: text-embedding-3-large
```

### Secrets

Secrets should not be stored in `config.yaml`. Use one of these approaches:

**Option A — `.env` file (recommended for development):**

```bash
# Create .env in your project root (this file is gitignored by .mdemgignore)
cat > .env << 'EOF'
OPENAI_API_KEY=sk-...
NEO4J_PASS=your-password
EOF
```

**Option B — System keychain (recommended for shared machines):**

```bash
mdemg config set-secret OPENAI_API_KEY sk-...
mdemg config set-secret NEO4J_PASS your-password

# Verify
mdemg config list-secrets
mdemg config get-secret OPENAI_API_KEY
```

**Option C — Environment variables:**

```bash
export OPENAI_API_KEY=sk-...
# Add to ~/.zshrc or ~/.bash_profile to persist across sessions
```

---

## Troubleshooting

### `mdemg: command not found` after install

```bash
# Close and reopen terminal, then:
mdemg version

# If still not found, check that Homebrew's bin is on PATH:
echo $PATH | tr ':' '\n' | grep -i brew
# Should include /opt/homebrew/bin (Apple Silicon) or /usr/local/bin (Intel)

# Fix for Apple Silicon:
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile
```

### Docker not running

```bash
docker info
# If error: "Cannot connect to the Docker daemon"
# → Open Docker Desktop from /Applications/Docker.app
# → Wait for menu bar icon to stop animating
# → Then retry: docker info
```

### Neo4j won't start

```bash
# Check container status
mdemg db status
docker ps -a --filter "name=mdemg-neo4j"

# View container logs
docker logs mdemg-neo4j-$(basename $(pwd))

# Common causes:
# 1. Docker Desktop not running → start it first
# 2. Port 7687 already in use → mdemg db start --port 7688
# 3. Previous container in bad state → mdemg db stop --remove && mdemg db start
```

### Neo4j port conflict

```bash
# Check what's using port 7687
lsof -i :7687

# Start Neo4j on a different port
mdemg db start --port 7688
```

### Server won't start

```bash
# Check server logs
cat .mdemg/logs/mdemg.log

# Check if something else is using port 9999
lsof -i :9999

# Try foreground mode to see errors directly
mdemg serve --auto-migrate
```

### Missing OpenAI key

```bash
# Check if key is set
echo $OPENAI_API_KEY

# Set it in .env
echo 'OPENAI_API_KEY=sk-...' >> .env

# Or via keychain
mdemg config set-secret OPENAI_API_KEY sk-...

# Restart server to pick up new config
mdemg restart
```

### Embedding check fails

```bash
mdemg embeddings check
# If it reports connection errors:
# 1. Check your API key: echo $OPENAI_API_KEY
# 2. Check network: curl -s https://api.openai.com/v1/models -H "Authorization: Bearer $OPENAI_API_KEY" | head -5
# 3. If using Ollama: verify it's running with `ollama list`
```

### Migrations fail

```bash
# Check current schema version
mdemg db status

# Try running migrations explicitly
mdemg db migrate

# If migrations report errors, check Neo4j connectivity
mdemg config validate
```

### Health check returns errors

```bash
curl -s http://localhost:9999/healthz | python3 -m json.tool
curl -s http://localhost:9999/readyz | python3 -m json.tool

# If server is not responding at all:
mdemg status
# If not running: mdemg start --auto-migrate
```

---

## Upgrading

```bash
brew update && brew upgrade mdemg

# Verify new version
mdemg version

# Apply any new database migrations
mdemg start --auto-migrate
# Or if already running:
mdemg restart
mdemg db migrate
```

---

## Uninstall

```bash
# 1. Stop the server and Neo4j
mdemg stop
mdemg db stop --remove

# 2. Remove Docker volumes (deletes all stored data)
docker volume ls -q --filter name=mdemg | xargs -r docker volume rm

# 3. Uninstall the CLI and remove the tap
brew uninstall mdemg
brew untap reh3376/mdemg

# 4. (Optional) Remove config and data directory
rm -rf .mdemg
```

---

## Man Pages

```bash
man mdemg
man mdemg-init
man mdemg-ingest
# Full list: ls $(brew --prefix)/share/man/man1/mdemg*
```

---

## Links

- [Source Code](https://github.com/reh3376/mdemg)
- [Windows Installation](https://github.com/reh3376/mdemg-windows)
- [Issues](https://github.com/reh3376/mdemg/issues)
