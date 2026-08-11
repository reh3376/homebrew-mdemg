# MDEMG Beta Tester README

**Welcome, and thank you for beta testing MDEMG.** This is your single-page onboarding index — everything you need to install, test, operate, troubleshoot, and report back.

**One-line link to hand another tester:** `https://github.com/reh3376/homebrew-mdemg/blob/main/README_BETA.md`

**Current beta:** `v0.11.0-beta.3` (2026-08-10) — see the [release notes](https://github.com/reh3376/mdemg/blob/main/docs/releases/v0.11.0-beta.3.md).

**Direct contact:** `rogerhenley345@gmail.com`

---

## Start here (30 minutes to first observation)

1. **Install** — [Install instructions](README.md) (this repo's main README). macOS via `brew`; Linux/WSL2 via `curl … install.sh`.
2. **Printable install checklist** — [`docs/beta/install-checklist.md`](https://github.com/reh3376/mdemg/blob/main/docs/beta/install-checklist.md). Fill in as you go through Tier 1; submit as a GitHub issue when done.
3. **First-hour value walkthrough** — Tier 2 of the [full beta plan](mdemg_beta_testing.md#tier-2--ingestion-10-tests).

---

## Full beta test plan (62 tests across 7 tiers, ~90–120 min)

The canonical test plan lives right next to this file: [`mdemg_beta_testing.md`](mdemg_beta_testing.md).

Tier map — each row is a self-contained testing block:

| Tier | Focus | Tests | Time |
|---|---|---|---|
| **T1** | [Installation & Core](mdemg_beta_testing.md#tier-1--installation--core) | 11 | ~30 min |
| **T2** | [Ingestion](mdemg_beta_testing.md#tier-2--ingestion-10-tests) | 10 | ~20 min |
| **T3** | [CMS & RSIC](mdemg_beta_testing.md#tier-3--cms--rsic-10-tests) | 10 | ~20 min |
| **T4** | [Backup & Maintenance](mdemg_beta_testing.md#tier-4--backup--maintenance-8-tests) | 8 | ~15 min |
| **T5** | [Advanced](mdemg_beta_testing.md#tier-5--advanced-10-tests) | 10 | ~30 min |
| **DC** | [Docker Compose & New Commands](mdemg_beta_testing.md#dc--docker-compose--new-commands-8-tests) | 8 | ~15 min |
| **DT** | [Data Collection & Training](mdemg_beta_testing.md#dt--data-collection--training-5-tests) | 5 | ~10 min |

Start with T1. The other tiers can be interleaved or picked based on interest.

---

## User documentation (link out)

Full documentation lives in the main [`mdemg` repo](https://github.com/reh3376/mdemg). Curated tester-relevant docs:

### CLI + API reference
- [`docs/user/cli-reference.md`](https://github.com/reh3376/mdemg/blob/main/docs/user/cli-reference.md) — every `mdemg <command>` with flags + examples
- [`docs/user/api-reference.md`](https://github.com/reh3376/mdemg/blob/main/docs/user/api-reference.md) — every HTTP endpoint (`/v1/…`)

### Getting-started guides
- [`docs/user/install-guide.md`](https://github.com/reh3376/mdemg/blob/main/docs/user/install-guide.md) — deep install walkthrough (macOS + Linux + WSL2)
- [`docs/user/quickstart-docker.md`](https://github.com/reh3376/mdemg/blob/main/docs/user/quickstart-docker.md) — Docker Compose lifecycle
- [`docs/user/ingestion-guide.md`](https://github.com/reh3376/mdemg/blob/main/docs/user/ingestion-guide.md) — feeding your code + docs into the substrate

### Concepts + operator
- [`docs/user/cms-rsic-guide.md`](https://github.com/reh3376/mdemg/blob/main/docs/user/cms-rsic-guide.md) — the Cognitive Memory Substrate + Recursive Self-Improvement Cycle
- [`docs/user/multi-instance.md`](https://github.com/reh3376/mdemg/blob/main/docs/user/multi-instance.md) — running two MDEMG installs side-by-side
- [`docs/user/neural-sidecar.md`](https://github.com/reh3376/mdemg/blob/main/docs/user/neural-sidecar.md) — the Python cross-encoder rerank sidecar

### Upgrades + versions
- [`docs/user/upgrade-guide.md`](https://github.com/reh3376/mdemg/blob/main/docs/user/upgrade-guide.md) — `mdemg upgrade` + Homebrew paths
- [Release notes for each beta](https://github.com/reh3376/mdemg/tree/main/docs/releases) — what shipped in beta.1, beta.2, beta.3, …

---

## The dashboard (`/ui`) and Grafana

Once MDEMG is running:

- **Main dashboard**: `http://localhost:9999/ui/` — Memory tab, Constraints, Jiminy, Config, Review
- **Grafana**: `http://localhost:3000` (login `admin` / `admin`) — 8 dashboards: overview, retrieval, jiminy, j17-protocol, rsic-ops, ft-training, hitl-curation, graph-topology

Feature-doc pointers (there are ~86 feature docs, most maintainer-facing; these are the tester-useful ones):

- [`docs/features/hitl-review.md`](https://github.com/reh3376/mdemg/blob/main/docs/features/hitl-review.md) — reviewing datasets in the UI Review tab
- [`docs/features/rsic-guidance-health-floors.md`](https://github.com/reh3376/mdemg/blob/main/docs/features/rsic-guidance-health-floors.md) — how to read the RSIC health panel
- [`docs/features/jiminy-strict.md`](https://github.com/reh3376/mdemg/blob/main/docs/features/jiminy-strict.md) — `/strict` mode deterministic enforcement

---

## Backups + data operations

- **Backup**: `mdemg data export` — UTDS-format tar.gz archive (privacy scrubbed at export time)
- **Automated backup**: `mdemg data export-auto --keep 7` — daily backups with retention + a `latest.tar.gz` symlink
- **TSDB backup + restore**: `mdemg tsdb status`, `mdemg tsdb migrate` (see [`docs/features/backup-restore.md`](https://github.com/reh3376/mdemg/blob/main/docs/features/backup-restore.md))
- **Graph repair**: `mdemg graph repair --space-id <id>` — dedup + orphan sweep + embedding backfill
- **Full teardown**: `mdemg teardown --export` (backs up TSDB before destroying containers)

---

## Reporting back — 3 issue templates

Every report lands at [`github.com/reh3376/mdemg/issues/new/choose`](https://github.com/reh3376/mdemg/issues/new/choose):

| Template | When to use |
|---|---|
| **🧪 Beta Install Report** | Complete Tier 1 (install + first boot). Structured PASS/FAIL for each of T1.1–T1.11. |
| **🐛 Beta Bug Report** | Any failure at any tier. Structured expected/actual + severity + reproducibility fields. |
| **💬 Beta Feature Friction** | "It worked, but was harder than it should have been." Docs gaps, unclear errors, ergonomic issues. |

### Attach a diagnostic bundle for faster triage

If you hit an issue, run:
```bash
mdemg diagnostics collect
# → writes ~/.mdemg/diagnostics/mdemg-diag-<host>-<ts>.tar.gz
# → drag that file into the GH issue
```

Every text field in the bundle passes through the same privacy scrubber the training-data export uses (`api_key` / `abs_path` / `env_secret` / `email` / `neo4j_cred` redacted; shell env-var references like `$PGPASSWORD` preserved). See [`docs/user/cli-reference.md#mdemg-diagnostics-collect`](https://github.com/reh3376/mdemg/blob/main/docs/user/cli-reference.md#mdemg-diagnostics-collect).

---

## Contributing training data (opt-in)

If you'd like to help improve MDEMG by sharing your recent activity (bounded, scrubbed, receipt-tracked):

```bash
mdemg beta-share --space-id <your-space> --since-days 7 --dry-run   # preview
mdemg beta-share --space-id <your-space> --since-days 7             # opt-in prompt, then bundle
# → prints a Submission ID
# → writes ~/.mdemg/beta-share/mdemg-beta-share-<ts>.tar.gz
# → drag that file into any GitHub issue
```

- **Fully opt-in per run** (interactive prompt; skippable with `--yes` for scripts)
- **PII scrubbed at export time** — if any PII survives the scan, the export BLOCKS and no bundle is produced
- **30-day maintainer-side retention** — deletion supported by email with the Submission ID as subject
- Each bundle contains a `README-BETA.md` and `submission_receipt.json` explaining what's inside

**Full tester-facing guide** — how it works end-to-end, what gets captured, where the bundle saves, how it reaches the maintainer, retention + deletion flow, troubleshooting: **[`docs/features/beta-share.md`](https://github.com/reh3376/mdemg/blob/main/docs/features/beta-share.md)**. Point questions at this file first.

Related: [`docs/features/hitl-auto-curation.md`](https://github.com/reh3376/mdemg/blob/main/docs/features/hitl-auto-curation.md#extending-to-the-guidance-dataset) covers how the maintainer curates the received data into the retrain corpus.

---

## Troubleshooting reference

| Symptom | Likely fix |
|---|---|
| `brew install mdemg` fails with Sorbet stack trace | Run `brew trust reh3376/mdemg` FIRST, then re-run tap + install. Documented in [install-checklist.md T1.1](https://github.com/reh3376/mdemg/blob/main/docs/beta/install-checklist.md#t11--install). |
| `mdemg config validate` prints FAILED on fresh install | If it says "services not started — run `docker compose up -d`", that's actually PASSED (exit 0); the wording is a next-step hint. If it says "errors found" (exit 1), file a bug. |
| Dashboard at `/ui/` shows blank Grafana panel | Grafana takes ~90 s to boot; wait + refresh. If persistent, `docker compose logs grafana` in your project directory. |
| Follow-rate panel reads much lower than expected | This is BY DESIGN. Honest steady state is 10–13%; panel titles show design-intent. See [`docs/development/jiminy-follow-rate-remeasure-001/verdict.md`](https://github.com/reh3376/mdemg/blob/main/docs/development/jiminy-follow-rate-remeasure-001/verdict.md). |
| `mdemg diagnostics collect` fails | File a bug with `docker compose ps`, tail of `~/.mdemg/logs/server.log`, and your OS/Docker versions. |

---

## Ending the beta

When beta.4 or v0.11.0 GA ships, you'll get:

- A release note in [`docs/releases/`](https://github.com/reh3376/mdemg/tree/main/docs/releases) with a Migration section covering breaking changes (currently NONE — betas are additive)
- An upgrade path: `brew upgrade mdemg && mdemg upgrade --docker-only`
- Notice on the [Beta Submissions Tracker](https://github.com/reh3376/mdemg/issues?q=is%3Aissue+label%3Abeta-submissions) if you submitted training data (it's kept 30 days from receipt)

---

## Direct contact

- **Email**: `rogerhenley345@gmail.com` — for anything you don't want to file as a public GH issue, especially deletion requests for opt-in training data submissions.
- **GitHub issues**: `https://github.com/reh3376/mdemg/issues` — every other tester-facing communication channel.

Thank you for helping shape MDEMG toward a General Availability release.

— Roger Henley
