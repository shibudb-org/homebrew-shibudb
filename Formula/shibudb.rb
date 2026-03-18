class Shibudb < Formula
  desc "Lightweight database engine with vector search support"
  homepage "https://github.com/shibudb-org/shibudb-server"
  url "https://github.com/shibudb-org/shibudb-server/archive/refs/tags/v1.0.4.tar.gz"
  sha256 "2ac9b7e8653ecde7c8e59682f21abfd5a691ccb984180331db5f2fa549add45f"
  license "AGPL-3.0-only"
  head "https://github.com/shibudb-org/shibudb-server.git", branch: "main"

  depends_on "go" => :build
  depends_on "faiss"

  def install
    faiss = Formula["faiss"]

    ENV["GOFLAGS"] = "-mod=mod"
    ENV["CGO_ENABLED"] = "1"
    ENV.append "CGO_CFLAGS", "-I#{faiss.opt_include}"
    ENV.append "CGO_CXXFLAGS", "-I#{faiss.opt_include}"
    ENV.append "CGO_LDFLAGS",
               "-L#{faiss.opt_lib} -lfaiss_c -lfaiss -Wl,-rpath,#{faiss.opt_lib}"

    ldflags = "-s -w -X main.Version=#{version}"

    system "go", "build",
           *std_go_args(ldflags: ldflags, output: bin/"shibudb"),
           "-tags=faiss",
           "."
  end

  def caveats
    <<~EOS
      The default service admin credentials are admin/admin.
      Change the admin password after first start:
        #{opt_bin}/shibudb connect --username admin --password admin 9090
        > update-user-password admin
    EOS
  end

  service do
    run [
      opt_bin/"shibudb", "start",
      "--data-dir", var/"lib/shibudb",
      "--admin-user", "admin",
      "--admin-password", "admin",
      "9090"
    ]
    keep_alive true
    log_path var/"log/shibudb.log"
    error_log_path var/"log/shibudb.log"
    working_dir var
  end

  test do
    assert_match "ShibuDB version #{version}", shell_output("#{bin}/shibudb --version")

    port = free_port
    data_dir = testpath/"shibudb-data"
    data_dir.mkpath

    pid = spawn(
      bin/"shibudb", "start",
      "--data-dir", data_dir.to_s,
      "--admin-user", "testadmin",
      "--admin-password", "testpass",
      port.to_s
    )

    require "socket"
    start_time = Time.now
    ready = false

    while Time.now - start_time < 30
      begin
        TCPSocket.open("127.0.0.1", port).close
        ready = true
        break
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        sleep 1
      end
    end

    begin
      assert_equal true, ready, "server did not become ready on port #{port}"

      output = pipe_output("#{bin}/shibudb connect --username testadmin --password testpass #{port}", "exit\n")
      assert_match(/successful/i, output)
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
