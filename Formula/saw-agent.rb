class SawAgent < Formula
  desc "SAW remote agent - pairs a machine with a SAW cloud workspace"
  homepage "https://github.com/LenderCom/saw-agent"
  version "0.1.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/LenderCom/homebrew-tap/releases/download/saw-agent-v0.1.0/saw-agent_v0.1.0_darwin_arm64.tar.gz"
      sha256 "653bcf48625313932f1160414d524ff675520232d0a31e89db19642918f586bd"
    else
      url "https://github.com/LenderCom/homebrew-tap/releases/download/saw-agent-v0.1.0/saw-agent_v0.1.0_darwin_amd64.tar.gz"
      sha256 "ae46b8f991d83c49ca43742342cea9614fe45167b7a3fb0848011ee8d1348c8c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/LenderCom/homebrew-tap/releases/download/saw-agent-v0.1.0/saw-agent_v0.1.0_linux_arm64.tar.gz"
      sha256 "57726ad2a86b8ec80bb5a3f66ba3d2d9110b9b29d90ba5284a790067c822aced"
    else
      url "https://github.com/LenderCom/homebrew-tap/releases/download/saw-agent-v0.1.0/saw-agent_v0.1.0_linux_amd64.tar.gz"
      sha256 "e2e8dc5ffe066131bc45f2d5dcda56de95e7616f9b8aab5496676a43ef0ab979"
    end
  end

  def install
    bin.install "saw-agent"
  end

  test do
    assert_match "saw-agent v0.1.0", shell_output("#{bin}/saw-agent --version")
  end
end
