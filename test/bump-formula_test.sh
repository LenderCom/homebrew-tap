#!/bin/bash
# Round-trips script/bump-formula.rb against a fixture manifest, on a scratch copy of the real
# formula, without touching Formula/saw-agent.rb or hitting the network. Run via `bin/test`.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT

formula_copy="$scratch/saw-agent.rb"
cp "$repo_root/Formula/saw-agent.rb" "$formula_copy"

ruby "$repo_root/script/bump-formula.rb" \
  "$repo_root/test/fixtures/manifest-v0.2.0.json" \
  "v0.2.0" \
  "$formula_copy"

fail=0

assert_contains() {
  if ! grep -qF -- "$1" "$formula_copy"; then
    echo "FAIL: expected formula to contain: $1"
    fail=1
  fi
}

assert_contains 'version "0.2.0"'
assert_contains 'url "https://github.com/LenderCom/saw-agent-releases/releases/download/v0.2.0/saw-agent_v0.2.0_darwin_arm64.tar.gz"'
assert_contains 'sha256 "1111111111111111111111111111111111111111111111111111111111111a"'
assert_contains 'url "https://github.com/LenderCom/saw-agent-releases/releases/download/v0.2.0/saw-agent_v0.2.0_linux_amd64.tar.gz"'
assert_contains 'sha256 "4444444444444444444444444444444444444444444444444444444444444d"'

# The parts the bump does NOT touch must survive untouched.
assert_contains 'def install'
assert_contains 'def shim_script'
assert_contains 'managed="$HOME/.saw/bin/saw-agent"'

ruby -c "$formula_copy" >/dev/null

# Re-running against the ALREADY-bumped copy (a second stable publish) must still match —
# idempotency depends on keying off the filename suffix, not the currently-live repo/tag.
ruby "$repo_root/script/bump-formula.rb" \
  "$repo_root/test/fixtures/manifest-v0.2.0.json" \
  "v0.2.0" \
  "$formula_copy"
assert_contains 'version "0.2.0"'

if [ "$fail" -ne 0 ]; then
  echo "bump-formula_test.sh: FAILED"
  exit 1
fi

echo "bump-formula_test.sh: OK"
