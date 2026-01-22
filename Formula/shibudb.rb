class Shibudb < Formula
  desc "Lightweight embedded database with KV and vector support"
  homepage "https://github.com/shibudb-org/shibudb-server"
  url "https://github.com/shibudb-org/shibudb-server/releases/download/v1.0.1/shibudb-1.0.1-darwin-arm64.tar.gz"
  sha256 "fcc2b998bb5598c361f3ceeaf0bb07caceae8cf3787a87fc007ce25a93ee697d"
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
