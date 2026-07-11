# protocols

Language-neutral contracts shared across the qte77 estate. A contract here is
a JSON Schema plus fixtures - no runtime, no SDK, no per-language code.
Consumers vendor a pinned tag and validate against it with whatever tool
their language already has (pydantic + jsonschema, ajv, check-jsonschema,
...).

## What

One launch contract: `workflow-definition/v1`.

It describes the shape of a "workflow" (Python side) / "usecase" (TS side)
definition: a stable `id`, an ordered `stages[]` execution plan, and an
optional `output` block describing where the result surfaces. `id` and
`stages[].name` are the only fields every engine must agree on; everything
else is engine-specific, documented in the schema's `$defs`, and
type-checked only when present.

```text
schemas/workflow-definition/v1/workflow-definition.schema.json  - the contract
fixtures/workflow-definition/v1/valid/                          - must PASS
fixtures/workflow-definition/v1/invalid/                         - must FAIL
scripts/sync.sh                                                  - vendor a pinned tag
.github/workflows/validate.yml                                   - the CI gate
```

Do not add a second contract to this repo unless a genuinely new
language-neutral shape is needed. One contract, done well, beats several
half-finished ones.

## How

### Consuming the contract

| Consumer | Language | Validator |
| --- | --- | --- |
| qte77/azure-doc-workflows | Python | pydantic model + `jsonschema` (or `check-jsonschema` in CI) against `workflow-definition/v1` |
| qte77/ldnmxx-hack (Cloudflare Worker) | TypeScript | `ajv` (draft 2020-12, with `ajv-formats`) against `workflow-definition/v1` |

Vendor a pinned tag into your repo with `scripts/sync.sh`:

```sh
curl -fsSL https://raw.githubusercontent.com/qte77/protocols/main/scripts/sync.sh | sh -s -- v1.0.0 vendor/protocols
```

or, if you have this repo checked out locally:

```sh
./scripts/sync.sh v1.0.0 vendor/protocols
```

This writes `vendor/protocols/schemas/workflow-definition/v1/...` and
`vendor/protocols/fixtures/workflow-definition/v1/...`. Never edit vendored
files by hand - re-run `sync.sh` with a new tag to bump the pinned version.

### Validating locally

```sh
npm install --no-save ajv-cli ajv-formats
npx ajv validate --spec=draft2020 -c ajv-formats \
  -s schemas/workflow-definition/v1/workflow-definition.schema.json \
  -d "fixtures/workflow-definition/v1/valid/*.json"

pip install check-jsonschema
check-jsonschema \
  --schemafile schemas/workflow-definition/v1/workflow-definition.schema.json \
  fixtures/workflow-definition/v1/valid/*.json
```

## Why

Two engines (a Python doc-processing pipeline and a TS Cloudflare Worker)
independently evolved their own "list of stages with a name/backend/model"
shape. Duplicating validation logic per engine drifts silently; a shared,
versioned, language-neutral schema is the single source of truth both sides
compile/validate against, without either engine depending on the other's
runtime.

### Versioning policy

- The schema lives at `schemas/workflow-definition/vN/`. `vN` only changes
  for a **breaking** change - most notably, adding a new **required** field.
  A new optional field, a loosened constraint, or a new documented
  engine-specific key is not breaking and stays within the same `vN`.
- Consumers pin an exact git tag (e.g. `v1.0.0`) via `scripts/sync.sh` -
  never track a branch. Bump the pin deliberately, in its own commit, and
  re-run the consumer's own validation before merging.
- Fixtures are part of the contract: every `valid/` fixture must validate
  and every `invalid/` fixture must fail, enforced by
  `.github/workflows/validate.yml` on every push and PR, using two
  independent validators (`ajv` and `check-jsonschema`) so dialect drift
  between implementations is caught.

## Refs

- Python engine models: `qte77/azure-doc-workflows` (`Workflow`/`Stage`,
  pydantic).
- TS engine models: `qte77/ldnmxx-hack` (`UsecaseDef`/`StageDef`,
  `worker/src/usecases.ts`).
- Per-language `system` prompts: `qte77/azure-doc-workflows#167`.
- Structural gate / `required_sections`: `qte77/azure-doc-workflows` ADR-0005.
- Cached prompt prefix / `cache_prefix`: `qte77/azure-doc-workflows` ADR-0006.

## License

Apache-2.0. See `LICENSE`.
