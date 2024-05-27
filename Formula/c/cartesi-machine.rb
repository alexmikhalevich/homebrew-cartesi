class CartesiMachine < Formula
  desc "Off-chain implementation of the Cartesi Machine"
  homepage "https://cartesi.io/"
  url "https://github.com/cartesi/machine-emulator/archive/refs/tags/v0.17.0.tar.gz"
  sha256 "2b3336eaa17bbacae749a46eb3af66e9745bc8708c86b3e5ba760a2e3482b831"
  license "LGPL-3.0-only"

  bottle do
    root_url "https://ghcr.io/v2/alexmikhalevich/blobs"
    sha256 arm64_sonoma:        "a81c2667be2e1982b8287d3e46612c5463e61a53cff792b965709b953c5825f8"
    sha256 x86_64_linux:        "37924e1d7fdf3215941063b80d6eb3b96019a6c849dbe8616cb278216d97bc52"
  end

  depends_on "pkg-config" => :build
  depends_on "wget" => :build
  depends_on "boost"
  depends_on "libslirp"
  depends_on "lua"
  depends_on "openssl"

  resource "pristine-hash" do
    url "https://github.com/cartesi/machine-emulator/releases/download/v0.17.0/uarch-pristine-hash.c"
    sha256 "0a02547680c126f564e0c4e7dc7878880ec519c4a3e20c9bd5a987827bc6a9ab"
  end

  resource "pristine-ram" do
    url "https://github.com/cartesi/machine-emulator/releases/download/v0.17.0/uarch-pristine-ram.c"
    sha256 "418c7d59fb889305ff4b182357afef1472d530fdb6e3c8c80ce78791e16426cb"
  end

  patch :DATA

  def install
    odie "pristine-hash resource needs to be updated" if version != resource("pristine-hash").version
    odie "pristine-ram resource needs to be updated" if version != resource("pristine-ram").version

    resource("pristine-hash").stage "uarch"
    resource("pristine-ram").stage "uarch"

    system "cat", "Makefile"
    system "make", "BREW_PREFIX=#{prefix}"
    system "make", "install-shared-libs", "-j1", "-d", "PREFIX=#{prefix}"
  end

  test do
    assert_match(/cartesi-machine #{version}/, shell_output("#{bin}/cartesi-machine --version | head -1"))
  end
end
__END__
diff --git a/Makefile b/Makefile
index f33e9c8..a111433 100644
--- a/Makefile
+++ b/Makefile
@@ -335,9 +335,6 @@ install-static-libs: $(LIB_INSTALL_PATH)
 
 install-shared-libs: $(LIB_INSTALL_PATH)
 	$(INSTALL_EXEC) $(EMU_TO_LIB) $(LIB_INSTALL_PATH)
-	$(SYMLINK) $(LIBCARTESI_SO) $(LIB_INSTALL_PATH)/$(LIBCARTESI)
-	$(SYMLINK) $(LIBCARTESI_SO_JSONRPC) $(LIB_INSTALL_PATH)/$(LIBCARTESI_JSONRPC)
-	$(STRIP_SHARED) $(subst src/,$(LIB_INSTALL_PATH)/,$(EMU_TO_LIB))
 
 install-lua-libs: $(LUA_INSTALL_PATH)/cartesi $(LUA_INSTALL_CPATH)/cartesi
 	$(INSTALL_FILE) $(EMU_LUA_TO_BIN) $(LUA_INSTALL_PATH)
diff --git a/src/Makefile b/src/Makefile
index 2a02886..f292acb 100644
--- a/src/Makefile
+++ b/src/Makefile
@@ -66,27 +66,30 @@ CXX=clang++
 AR=libtool -static -o
 INCS=
 
+BREW_PREFIX=$(shell which brew)
+PORT_PREFIX=$(shell which port)
+
 ifeq ($(MACOSX_DEPLOYMENT_TARGET),)
 export MACOSX_DEPLOYMENT_TARGET := $(shell sw_vers -productVersion | sed -E "s/([[:digit:]]+)\.([[:digit:]]+)\..+/\1.\2.0/")
 endif
 
 # Homebrew installation
-ifneq (,$(shell which brew))
-BREW_PREFIX = $(shell brew --prefix)
+ifneq (,$(BREW_PREFIX))
 BOOST_LIB_DIR=-L$(BREW_PREFIX)/lib
 BOOST_INC=-I$(BREW_PREFIX)/include
 SLIRP_LIB=-L$(BREW_PREFIX)/lib -lslirp
 SLIRP_INC=-I$(BREW_PREFIX)/libslirp/include
 
 # Macports installation
-else ifneq (,$(shell which port))
-PORT_PREFIX = /opt/local
+else ifneq (,$(PORT_PREFIX))
 BOOST_LIB_DIR=-L$(PORT_PREFIX)/libexec/boost/1.81/lib
 BOOST_INC=-I$(PORT_PREFIX)/libexec/boost/1.81/include
 SLIRP_LIB=-L$(PORT_PREFIX)/lib -lslirp
 SLIRP_INC=-I$(PORT_PREFIX)/include
+
 else
-$(error Neither Homebrew nor MacPorts is installed)
+$(warning BREW_PREFIX=$(BREW_PREFIX))
+$(warning Neither Homebrew nor MacPorts prefix found)
 endif
 
 LIBCARTESI=libcartesi-$(EMULATOR_VERSION_MAJOR).$(EMULATOR_VERSION_MINOR).dylib
