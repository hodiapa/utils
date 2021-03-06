# gcc-core

GCC-CORE := gcc-core
GCC-CORE_VERSION := git
GCC-CORE_PKG := gcc-$(GCC-CORE_VERSION).tar.xz
GCC-CORE_URL := git://gcc.gnu.org/git/gcc.git --depth=1
GCC-CORE_CFG := --target=$(TARGET) --disable-multilib --enable-languages=c,c++,go \
	--disable-ppl-version-check --disable-cloog-version-check --disable-isl-version-check \
    --enable-lto --enable-cloog-backend=isl --enable-static --disable-shared \
    --with-sysroot=$(PREFIX) --prefix=$(PREFIX) --with-gmp=$(PREFIX)/$(BUILD) \
	--with-mpfr=$(PREFIX)/$(BUILD) --with-mpc=$(PREFIX)/$(BUILD) \
	--with-isl=$(PREFIX)/$(BUILD) --with-cloog=$(PREFIX)/$(BUILD)

PKGS += $(GCC-CORE)
ifeq ($(call need_pkg,"gcc-core"),)
PKGS_FOUND += $(GCC-CORE)
endif

DEPS_$(GCC-CORE) = gmp mpfr mpc isl cloog binutils mingw-w64-headers

ifeq ($(TARGET),i686-w64-mingw32)
DEPS_$(GCC) += mingw-w64-headers $(DEPS_mingw-w64-headers)
endif

$(TARBALLS)/$(GCC-CORE_PKG):
	$(call download_git,$(GCC-CORE_URL))

.sum-$(GCC-CORE): $(GCC-CORE_PKG)

$(GCC): $(GCC-CORE_PKG) .sum-$(GCC-CORE)
	$(UNPACK)
	$(MOVE)

.$(GCC-CORE): $(GCC)
#	cd $< && $(RECONF)
#	cd $< && NOCONFIGURE=1 ./autogen.sh
#	cd $< && ./autogen.sh --no-configure
	mkdir -p $<-build
ifndef HAVE_CROSS_COMPILE
	cd $<-build && ../$</configure $(GCC-CORE_CFG)
else
	cd $<-build && ../$</configure $(GCC-CORE_CFG)
endif
	cd $<-build && $(MAKE) all-gcc install-gcc
	touch $@
