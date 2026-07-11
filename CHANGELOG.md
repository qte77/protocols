# Changelog

All notable changes to this repo are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Contract versioning (`vN` directories under `schemas/` and `fixtures/`) is
described in `README.md`; this file tracks changes to the repo as a whole.

## [Unreleased]

### Added

- `workflow-definition/v1`: the launch contract. JSON Schema (draft 2020-12)
  for a language-neutral workflow/usecase definition, covering the shared
  `id` + ordered `stages[].name` envelope, the Python engine's
  `backend`/`model`/`cache_prefix`/`rubric`/`judge`/`system` stage fields
  (including per-language `system` prompts), the TS engine's
  `events`/`exec` stage fields, and an `output` block that is a `oneOf` of
  the two engines' output shapes.
- Fixtures under `fixtures/workflow-definition/v1/`: real-world examples
  converted from `azure-doc-workflows` (`image-triage.yaml`) and
  `ldnmxx-hack` (`founders-copilot.json`, renamed `span` to `name`), a
  minimal example, a per-language `system` example, and four invalid
  fixtures covering the schema's core failure modes.
- `scripts/sync.sh`: vendor a pinned tag of the schema + fixtures into a
  consumer repo.
- `.github/workflows/validate.yml`: CI gate validating every fixture with
  both `ajv` (node) and `check-jsonschema` (python), plus a gitleaks scan.
