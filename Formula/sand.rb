class Sand < Formula
  desc "Run ephemeral macOS VMs via Tart and provision inside each VM"
  homepage "https://github.com/khoi/sand"
  url "https://github.com/khoi/sand/archive/refs/tags/v1.0.3.tar.gz"
  sha256 "197d75e763c4c886729c9b1b93b88e4724ed5714286420b5cc6982bbbb8b1dfb"
  head "https://github.com/khoi/sand.git", branch: "main"

  bottle do
    root_url "https://github.com/khoi/sand/releases/download/v1.0.3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "b6ef95f0c78c20dc565c5f4d2af2b1edb4da74e757597e8ce51bb26ef69cea37"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "6d5bf12db885c3846d53bfc6e6e5e8dd6eb5314f6d6371d09d6deb71087b025c"
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
