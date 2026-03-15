class Shibudb < Formula
  desc "Lightweight embedded database with KV and vector support"
  homepage "https://github.com/shibudb-org/shibudb-server"
  url "https://github.com/shibudb-org/shibudb-server/releases/download/v1.0.2/shibudb-1.0.2-darwin-arm64.tar.gz"
  sha256 "a1940ebc28c8080d586ae03fee9435bdaf198063e9108ef510b0caa11b8895c3"
  version "1.0.1"
  license "AGPL3"

  def install
    bin.install "shibudb"
    lib.install "libfaiss.dylib", "libfaiss_c.dylib"
  end

  test do
    system "#{bin}/shibudb", "--help"
  end
end
