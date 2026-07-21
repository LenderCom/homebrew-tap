# LenderCom Homebrew tap

Homebrew formulae for LenderCom developer tools.

## Install

```sh
brew install lendercom/tap/saw-agent
```

No `brew tap` step needed — the fully-qualified name taps this repository automatically.

Prefer curl? The same binaries install via:

```sh
curl -fsSL https://lendercom.github.io/get/agent | sh
```

## What's in here

| Formula | Description |
|---|---|
| `saw-agent` | SAW remote agent — pairs a macOS/Linux machine with a SAW cloud workspace |

Binaries are prebuilt (statically linked, CGO-free) from the private
[`LenderCom/saw-agent`](https://github.com/LenderCom/saw-agent) source repo and published as
release assets **on this repository** (tag `saw-agent-v<version>`), so they are publicly
downloadable while the source stays private.

## Releasing a new saw-agent version

See [RELEASING.md](RELEASING.md). In short: build the four-platform matrix with an explicit
`VERSION=vX.Y.Z` from the clean tagged commit, package each binary as
`saw-agent_vX.Y.Z_<os>_<arch>.tar.gz` (inner file named exactly `saw-agent`), publish a
`saw-agent-vX.Y.Z` release here with the tarballs + `SHA256SUMS`, then update
`Formula/saw-agent.rb` (version + urls + sha256s) and the install script in
[`LenderCom/get`](https://github.com/LenderCom/get).
