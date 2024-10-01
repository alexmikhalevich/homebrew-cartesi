class CartesiMachineRootfs < Formula
  desc "Root filesystem for the Cartesi Machine Emulator"
  homepage "https://github.com/cartesi/machine-emulator-tools"
  version "0.16.2"
  url "https://github.com/cartesi/machine-emulator-tools/releases/download/v#{version}-test1/rootfs-tools-v#{version}.ext2"
  sha256 "bf82f702229cea00156a2306149f018dc5aab85f176846a1b06a4bee561f72a3"
  license "Apache-2"

  def install
    share.install "rootfs-tools-v#{version}.ext2"
    (etc/"cartesi").install_symlink share/"rootfs-tools-v#{version}.bin" => "rootfs.ext2"
  end

  test do
    assert_predicate share/"rootfs.ext2", :exist?
  end
end
