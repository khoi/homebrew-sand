class Sand < Formula
  desc "Run ephemeral macOS VMs via Tart and provision inside each VM"
  homepage "https://github.com/khoi/sand"
  url "https://github.com/khoi/sand/archive/refs/tags/v1.0.1.tar.gz"
  sha256 "a8d6b86e07827538a73c2b1bf7b03b8aafec093b8cd3e89945fd6391674326f7"
  head "https://github.com/khoi/sand.git", branch: "main"

  bottle do
    root_url "https://github.com/khoi/sand/releases/download/v1.0.1"
    rebuild 3
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
