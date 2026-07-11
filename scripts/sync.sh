#!/bin/sh
# sync.sh - vendor a pinned qte77/protocols tag into a consumer repo.
#
# This repo publishes exactly one contract: workflow-definition/v1. Consumers
# (qte77/azure-doc-workflows, qte77/ldnmxx-hack) should never point at a
# moving branch - pin a git tag and re-run this script to bump it deliberately.
#
# Usage:
#   ./sync.sh <tag> <target-dir>
#
# Example:
#   ./sync.sh v1.0.0 vendor/protocols
#
# Writes (relative to <target-dir>):
#   schemas/workflow-definition/v1/workflow-definition.schema.json
#   fixtures/workflow-definition/v1/valid/*.json
#   fixtures/workflow-definition/v1/invalid/*.json
#
# Requires: curl.
#
# NOTE: the fixture name lists below must be kept in sync with
# fixtures/workflow-definition/v1/{valid,invalid}/ in this repo. If a fixture
# is added or removed here, update this script in the same change.
set -eu

REPO="qte77/protocols"
TAG="${1:?usage: sync.sh <tag> <target-dir>}"
TARGET="${2:?usage: sync.sh <tag> <target-dir>}"
RAW="https://raw.githubusercontent.com/${REPO}/${TAG}"
CONTRACT="workflow-definition/v1"

VALID_FIXTURES="azure-image-triage ldnmxx-founders-copilot minimal system-per-language"
INVALID_FIXTURES="empty-stages stage-missing-name bad-output non-string-id"

mkdir -p \
  "${TARGET}/schemas/${CONTRACT}" \
  "${TARGET}/fixtures/${CONTRACT}/valid" \
  "${TARGET}/fixtures/${CONTRACT}/invalid"

fetch() {
  # $1 = path relative to repo root; written to the same relative path under TARGET.
  src="$1"
  echo "fetching ${src}" >&2
  curl -fsSL "${RAW}/${src}" -o "${TARGET}/${src}"
}

fetch "schemas/${CONTRACT}/workflow-definition.schema.json"

for name in ${VALID_FIXTURES}; do
  fetch "fixtures/${CONTRACT}/valid/${name}.json"
done
for name in ${INVALID_FIXTURES}; do
  fetch "fixtures/${CONTRACT}/invalid/${name}.json"
done

echo "synced ${REPO}@${TAG} (${CONTRACT}) -> ${TARGET}" >&2
