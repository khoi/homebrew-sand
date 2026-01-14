class Sand < Formula
  desc "Run ephemeral macOS VMs via Tart and provision inside each VM"
  homepage "https://github.com/khoi/sand"
  url "https://github.com/khoi/sand/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "7f11806f87b47529db8457e1292a5daa70e39c9e45efe0f50ab6e46fdc13c4a0"
  head "https://github.com/khoi/sand.git", branch: "main"

  bottle do
    root_url "https://github.com/khoi/sand/releases/download/v1.0.1"
    rebuild 2
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "14baabbc91cc6f5ba75fbebabd81d2609622b0ac605621699b66c6fa476a7d80"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "916406b847d6bbf4e845a252b1798ffc7b28cd48d112b266f0d841330a525bc2"
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
