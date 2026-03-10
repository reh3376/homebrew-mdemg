# typed: false
# frozen_string_literal: true

class Mdemg < Formula
  desc "Multi-Dimensional Emergent Memory Graph — cognitive substrate for AI agents"
  homepage "https://github.com/reh3376/mdemg"
  version "0.2.1"
  depends_on :macos

  if Hardware::CPU.arm?
    url "https://github.com/reh3376/mdemg/releases/download/v0.2.1/mdemg_0.2.1_darwin_arm64.tar.gz"
    sha256 "68f4b6b449b6e5c041218e162e4b1b0603d7be6870c8ea6c7a90831967f98d7b"
  elsif Hardware::CPU.intel?
    url "https://github.com/reh3376/mdemg/releases/download/v0.2.1/mdemg_0.2.1_darwin_amd64.tar.gz"
    sha256 "da349922467bd5b4b543df41067798819cbe97b9b1c26622447a139474500dd8"
  end

  def install
    bin.install "mdemg"
  end

  test do
    system "#{bin}/mdemg", "version"
  end
end
