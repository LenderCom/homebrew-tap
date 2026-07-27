# Releasing saw-agent

The source repo (`LenderCom/saw-agent`) is private; release artifacts are public so `brew
install`/the curl installer work without credentials.

## The formula bump is automated — do not hand-run the script

Steps 4-6 below are **history**, kept only for a manual recovery. The live flow is:

1. Tag `vX.Y.Z` on `LenderCom/saw-agent`. Its `release.yml` builds the matrix, signs
   `manifest.json`, and publishes the release on `LenderCom/saw-agent-releases`.
2. [`bump-formula.yml`](.github/workflows/bump-formula.yml) here polls that repo hourly, picks the
   newest non-prerelease tag, runs [`script/bump-formula.rb`](script/bump-formula.rb) against the
   signed manifest, verifies (`ruby -c`, `brew style`, `test/bump-formula_test.sh`, and an HTTP
   check on the four new urls), and **opens the bump PR**. Merge it.
3. [`tap-canary.yml`](.github/workflows/tap-canary.yml) then installs the merged formula on real
   macOS + Linux runners hourly and files an issue if anything is wrong.

It polls rather than being dispatched from `saw-agent` on purpose: a cross-repo dispatch needs a
write token held over there, and an expiring token silently stops release propagation. Polling a
public repo needs no credential. `workflow_dispatch` (tag optional) forces a bump early;
`repository_dispatch: saw-agent-stable-release` is still accepted if a sending half is ever added.

`saw-agent-dev` is the same story via
[`bump-formula-dev.yml`](.github/workflows/bump-formula-dev.yml), except it pushes straight to
`main` — the dev channel prunes to the newest 5 prereleases, so a bump parked in a PR outlives the
release it pins.

---

## Manual recovery recipe

Only if the automation is broken. Pin the Go toolchain named in `saw-agent/go.mod` — a different
toolchain changes the binaries and therefore the checksums (v0.1.0 was built with go1.26.5).

```sh
# 1. From a CLEAN checkout of LenderCom/saw-agent at the commit to release:
git tag vX.Y.Z && git push origin vX.Y.Z

# 2. Build the matrix with an EXPLICIT version stamp (never trust `git describe`
#    from a possibly-dirty tree — a wrong stamp poisons `saw-agent --version`
#    and the formula's `test do`):
VERSION=vX.Y.Z COMMIT=$(git rev-parse --short=12 HEAD) make release

# 3. Package: each tarball contains a single file named exactly `saw-agent`
#    (the formula's `libexec.install "saw-agent"` and the install script depend on it):
cd dist
for p in darwin_amd64 darwin_arm64 linux_amd64 linux_arm64; do
  mkdir -p pkg/$p && cp saw-agent_$p pkg/$p/saw-agent
  tar -czf saw-agent_vX.Y.Z_$p.tar.gz -C pkg/$p saw-agent
done
shasum -a 256 saw-agent_vX.Y.Z_*.tar.gz > SHA256SUMS
rm -rf pkg

# 4. Publish the PUBLIC release on THIS repo (assets must be anonymously
#    downloadable; saw-agent's own releases are private):
gh release create saw-agent-vX.Y.Z --repo LenderCom/homebrew-tap \
  --title "saw-agent vX.Y.Z" --notes "..." \
  saw-agent_vX.Y.Z_*.tar.gz SHA256SUMS

# 5. Update Formula/saw-agent.rb: version, the four urls, the four sha256s.
#    Verify: brew update && brew upgrade saw-agent (or brew install), then
#    brew test lendercom/tap/saw-agent.

# 6. Update SAW_AGENT_VERSION + checksums freshness in LenderCom/get's `agent`
#    script (it pins the version so installs are deterministic and never hit
#    the rate-limited GitHub API).
```
