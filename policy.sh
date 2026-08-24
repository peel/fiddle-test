#!/usr/bin/env bash
set -euo pipefail

if [ -n "${FIDDLE_TEST_POLICY_GATE:-}" ]; then
  echo "release policy: a dependency change needs sign-off from a maintainer," >&2
  echo "recorded outside this repository. Nothing in the tree can satisfy it." >&2
  exit 1
fi

echo "release policy: no gate is armed"
