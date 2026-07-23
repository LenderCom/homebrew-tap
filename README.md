# LenderCom Homebrew tap

Homebrew formulae for LenderCom developer tools.

## Install

```sh
brew install lendercom/tap/saw-agent
```

No `brew tap` step needed — the fully-qualified name taps this repository automatically.
`brew info lendercom/tap/saw-agent` (or the caveats a fresh install prints) has the next step:
pairing the machine with a SAW cloud workspace.

Tracking internal dev builds instead of the stable release? Use the dev-channel formula:

```sh
brew install lendercom/tap/saw-agent-dev
```

It installs as `saw-agent-dev` (not `saw-agent`) so both can coexist, and always tracks the
latest pre-release cut from [`LenderCom/saw-agent-releases`](https://github.com/LenderCom/saw-agent-releases)
(several a day — see [`bump-formula-dev.yml`](.github/workflows/bump-formula-dev.yml)).

Prefer curl? The same binaries install via:

```sh
curl -fsSL https://get.sawrun.com/agent | sh -s -- --channel stable   # or --channel dev
```

### Troubleshooting: "Refusing to load formula ... from untrusted tap"

If `brew install`/`brew list` refuses `lendercom/tap/...` with an untrusted-tap error, trust the
tap once:

```sh
brew trust --tap lendercom/tap
```

(Homebrew's tap-trust store is per-machine, `~/.homebrew/trust.json` — a stale or mistyped entry
there, e.g. an old `lendercom/test-tap` from before this tap's current name, silently blocks every
install from `lendercom/tap` with no indication a prior install ever partially worked.)

## What's in here

| Formula | Description |
|---|---|
| `saw-agent` | SAW remote agent, stable channel — pairs a macOS/Linux machine with a SAW cloud workspace |
| `saw-agent-dev` | SAW remote agent, dev channel — same pairing flow, tracks the latest `saw-agent-releases` pre-release |

Binaries are prebuilt (statically linked, CGO-free) from the private
[`LenderCom/saw-agent`](https://github.com/LenderCom/saw-agent) source repo, publicly downloadable
while the source stays private. `saw-agent-dev` already pulls its release assets from the
dedicated [`LenderCom/saw-agent-releases`](https://github.com/LenderCom/saw-agent-releases) repo
(provisioned; dev-channel tags land there several times a day). `saw-agent` (stable) still points
at this tap repo's own `saw-agent-v0.1.0` release — no stable tag has published to
`saw-agent-releases` yet — and will migrate the same way the first time
[`bump-formula.yml`](.github/workflows/bump-formula.yml) runs against a stable tag there; no
manual step needed here when that happens.

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
