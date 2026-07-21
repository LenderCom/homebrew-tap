# Releasing saw-agent

The source repo (`LenderCom/saw-agent`) is private; this public tap repo carries the
release artifacts. Until a CI release workflow lands in `saw-agent`, the recipe is manual.
Pin the Go toolchain named in `saw-agent/go.mod` — a different toolchain changes the
binaries and therefore the checksums (v0.1.0 was built with go1.26.5).

```sh
# 1. From a CLEAN checkout of LenderCom/saw-agent at the commit to release:
git tag vX.Y.Z && git push origin vX.Y.Z

# 2. Build the matrix with an EXPLICIT version stamp (never trust `git describe`
#    from a possibly-dirty tree — a wrong stamp poisons `saw-agent --version`
#    and the formula's `test do`):
VERSION=vX.Y.Z COMMIT=$(git rev-parse --short=12 HEAD) make release

# 3. Package: each tarball contains a single file named exactly `saw-agent`
#    (the formula's `bin.install "saw-agent"` and the install script depend on it):
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
