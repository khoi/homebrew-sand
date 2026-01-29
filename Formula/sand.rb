class Sand < Formula
  desc "Run ephemeral macOS VMs via Tart and provision inside each VM"
  homepage "https://github.com/khoi/sand"
  url "https://github.com/khoi/sand/archive/refs/tags/v1.3.6.tar.gz"
  sha256 "53637ecebf2302e33ad30f3fa062b54357275e6a7a94c4619ef235db4b2e1679"
  head "https://github.com/khoi/sand.git", branch: "main"

  bottle do
    root_url "https://github.com/khoi/sand/releases/download/v1.3.6"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "8efb4bb6f4f957668a5c5d18e367ee3ef45e1a244a128d0821340c3684cb7d88"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "aa1b6683156f6163123a490bf3e79dfa1a2536529f113bb6d2ef796e66b00f01"
  end

  depends_on :macos
  depends_on "sshpass"
  depends_on "cirruslabs/cli/tart"

  def install
    # Avoid requiring SSH credentials during SwiftPM dependency fetches.
    ssh_url = "git@github.com:apple/swift-log.git"
    https_url = "https://github.com/apple/swift-log.git"
    if File.exist?("Package.swift") && File.read("Package.swift").include?(ssh_url)
      inreplace "Package.swift", ssh_url, https_url
    end
    if File.exist?("Package.resolved") && File.read("Package.resolved").include?(ssh_url)
      inreplace "Package.resolved", ssh_url, https_url
    end

    swift = ENV["HOMEBREW_SWIFT"] || "swift"
    system swift, "build", "--disable-sandbox", "-c", "release"
    bin.install ".build/release/sand"
  end

  test do
    system bin/"sand", "--help"
  end

  def caveats
    <<~EOS
      sand requires macOS 15+ and Tart available in your PATH.
    EOS
  end
end
