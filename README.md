# LenderCom Homebrew tap

Homebrew formulae for LenderCom developer tools.

## Install

```sh
brew install lendercom/tap/saw-agent
```

No `brew tap` step needed — the fully-qualified name taps this repository automatically.

Prefer curl? The same binaries install via:

```sh
curl -fsSL https://get.sawrun.com/agent | sh
```

## What's in here

| Formula | Description |
|---|---|
| `saw-agent` | SAW remote agent — pairs a macOS/Linux machine with a SAW cloud workspace |

Binaries are prebuilt (statically linked, CGO-free) from the private
[`LenderCom/saw-agent`](https://github.com/LenderCom/saw-agent) source repo and published as
release assets **on this repository** (tag `saw-agent-v<version>`), so they are publicly
downloadable while the source stays private. This will migrate to the dedicated
[`LenderCom/saw-agent-releases`](https://github.com/LenderCom/saw-agent-releases) repo once that's
provisioned (see "Releasing" below) — no action needed here, the automated bump repoints the
formula's urls on its own the first time it runs against the new repo.

## What `saw-agent` installs

The keg carries the real, versioned binary; `saw-agent` on your `PATH` is a small shim that execs
`~/.saw/bin/saw-agent` if the agent has since self-updated itself there, otherwise the keg copy.
`brew upgrade` always refreshes that keg fallback, never the self-updated install — see the
formula's `caveats` (`brew info saw-agent`) for the full picture.

## Releasing a new saw-agent version

See [RELEASING.md](RELEASING.md). Short version, once `LenderCom/saw-agent-releases` + its stable
lane (saw-agent-auto-update-plan.md §2.7, ticket B1) exist: a stable tag there publishes a signed
manifest and dispatches [`bump-formula.yml`](.github/workflows/bump-formula.yml), which rewrites
`Formula/saw-agent.rb`'s version/urls/sha256s and opens a PR here automatically — no manual step.
Until then (or for a manual re-bump), run `script/bump-formula.rb` yourself; see RELEASING.md.
