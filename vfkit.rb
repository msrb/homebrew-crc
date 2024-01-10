class Vfkit < Formula
  desc "Command line hypervisor using Apple's Virtualization Framework"
  homepage "https://github.com/crc-org/vfkit"
  url "https://github.com/crc-org/vfkit.git",
      tag: "v0.5.0",
      revision: "7572104e0d9c622b32fb48813c41dd10da9b9fa7"
  license "Apache-2.0"
  head "https://github.com/crc-org/vfkit.git", branch: "main"

  depends_on "go" => :build

  patch do
    url "https://github.com/crc-org/vfkit/commit/732de99a184e83c11e245f4f0d4e03ccedddb4f5.patch"
    sha256 "9954a9835f2fff0e851e51f3fe8b414cadd5c699d53fd9da577ba88f0620e502"
  end

  def install
    ENV["CGO_ENABLED"] = "1"
    ENV["CGO_CFLAGS"] = "-mmacosx-version-min=11.0"
    ENV["GOOS"]="darwin"
    arch = Hardware::CPU.intel? ? "amd64" : Hardware::CPU.arch.to_s
    system "make", "out/vfkit-#{arch}"
    bin.install "out/vfkit-#{arch}" => "vfkit"
  end

  test do
    # test version
    version_output = shell_output("#{bin}/vfkit --version 2>&1").strip
    assert_match(/vfkit version: #{version}/, version_output)

    # start a VM with non-existing kernel
    lines =  shell_output("#{bin}/vfkit --kernel foo --initrd bar --kernel-cmdline baz 2>&1", 1).strip.split(/\r?\n|\r/)
    assert_match(/open foo: no such file or directory/, lines.last)
  end
end

