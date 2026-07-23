#!/usr/bin/env ruby
# frozen_string_literal: true

# Rewrites Formula/saw-agent.rb's version + per-platform url/sha256 from a saw-agent-releases
# manifest.json (saw-agent-auto-update-plan.md §2.2: {version, channel, commit, artifacts:
# [{os, arch, name, sha256}], ...}). This is the receiving half of the stable-lane automated bump
# (plan §2.7/§2.11); the sending half — dispatching this repo on a stable publish — lands in
# saw-agent's release workflow (ticket B1) and is not yet wired, so today this only runs manually
# or via `workflow_dispatch` until that dispatch exists.
#
# Usage: bump-formula.rb <manifest.json path-or-URL> <release-tag> [formula-path]

require "json"
require "open-uri"
require "pathname"

RELEASES_REPO = "LenderCom/saw-agent-releases"

# Keyed by the filename suffix the release matrix has used since v0.1.0 (Formula/saw-agent.rb,
# get's `agent` script) — matching on that suffix, not on which repo/tag is live, is what makes a
# re-run idempotent across the eventual homebrew-tap -> saw-agent-releases cutover.
PLATFORM_SUFFIXES = {
  %w[darwin arm64] => "darwin_arm64",
  %w[darwin amd64] => "darwin_amd64",
  %w[linux arm64] => "linux_arm64",
  %w[linux amd64] => "linux_amd64",
}.freeze

def load_manifest(source)
  json = source.start_with?("http://", "https://") ? URI.parse(source).read : File.read(source)
  JSON.parse(json)
end

def bump(manifest_source:, tag:, formula_path:)
  manifest = load_manifest(manifest_source)
  version = manifest.fetch("version")
  artifacts = manifest.fetch("artifacts")

  by_suffix = artifacts.each_with_object({}) do |artifact, memo|
    suffix = PLATFORM_SUFFIXES[[artifact.fetch("os"), artifact.fetch("arch")]]
    memo[suffix] = artifact if suffix # skip platforms the formula doesn't ship (e.g. windows)
  end

  missing = PLATFORM_SUFFIXES.values - by_suffix.keys
  raise "manifest #{manifest_source} is missing artifacts for: #{missing.join(", ")}" unless missing.empty?

  formula = formula_path.read
  formula = formula.sub(/^(\s*)version ".*"$/, "\\1version \"#{version}\"")

  by_suffix.each do |suffix, artifact|
    url = "https://github.com/#{RELEASES_REPO}/releases/download/#{tag}/#{artifact.fetch("name")}"
    sha256 = artifact.fetch("sha256")

    pattern = /url ".*_#{Regexp.escape(suffix)}\.tar\.gz"\n(\s*)sha256 ".*"/
    raise "formula has no existing url/sha256 pair for platform #{suffix}" unless formula.match?(pattern)

    formula = formula.sub(pattern, "url \"#{url}\"\n\\1sha256 \"#{sha256}\"")
  end

  formula_path.write(formula)
  version
end

if $PROGRAM_NAME == __FILE__
  manifest_source, tag, formula_path = ARGV
  if manifest_source.nil? || tag.nil?
    warn "usage: bump-formula.rb <manifest.json path-or-URL> <release-tag> [formula-path]"
    exit 1
  end

  formula_path ||= (Pathname.new(__dir__).parent + "Formula/saw-agent.rb").to_s
  version = bump(manifest_source: manifest_source, tag: tag, formula_path: Pathname.new(formula_path))
  puts "Bumped #{formula_path} to #{version} (#{RELEASES_REPO}@#{tag})"
end
