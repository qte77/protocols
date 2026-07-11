# AGENTS.md - protocols

Operating rules for agents working in this repo.

## What this is

Language-neutral contracts (JSON Schema + fixtures) shared across the qte77
estate - no runtime, no SDK, no per-language code. See `README.md` for the
full scope and versioning policy.

## Rules

- One contract per genuinely new language-neutral shape. The current launch
  contract is `workflow-definition/v1`; do not add a second contract
  speculatively (YAGNI).
- Contracts are versioned by directory: `schemas/<contract>/vN/` and
  `fixtures/<contract>/vN/`. A new **required** field is a breaking change
  and gets a new `vN`; anything additive/optional stays in the current `vN`.
- Every schema change must keep all of `fixtures/<contract>/vN/valid/*`
  passing and all of `fixtures/<contract>/vN/invalid/*` failing. Add
  fixtures alongside schema changes, in the same commit/PR.
- `.github/workflows/validate.yml` is the gate: it runs both `ajv` and
  `check-jsonschema` against every fixture, plus a gitleaks scan. A schema
  or fixture PR is not done until this workflow is green.
- Commits: Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`, ...).
- Action refs in workflows are SHA-pinned with the tag noted in a trailing
  comment (`uses: owner/repo@<sha>  # vX`); update both the SHA and comment
  together when bumping.
- Plain text output only - no emoji or status glyphs, per estate convention.
