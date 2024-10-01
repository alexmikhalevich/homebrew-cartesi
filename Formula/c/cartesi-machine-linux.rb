class CartesiMachineLinux < Formula
  desc "Linux kernel for the Cartesi Machine Emulator"
  homepage "https://github.com/cartesi/image-kernel"
  version "0.20.0"
  url "https://github.com/cartesi/image-kernel/releases/download/v#{version}/linux-6.5.13-ctsi-1-v#{version}.bin"
  sha256 "65dd100ff6204346ac2f50f772721358b5c1451450ceb39a154542ee27b4c947"
  license "GPL-2"

  def install
    share.install "linux-6.5.13-ctsi-1-v#{version}.bin"
    (etc/"cartesi").install_symlink share/"linux-6.5.13-ctsi-1-v#{version}.bin" => "linux.bin"
  end

  test do
    assert_predicate etc/"cartesi/linux.bin", :exist?
  end
end
