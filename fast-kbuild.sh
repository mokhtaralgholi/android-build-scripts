#/bin/bash

## Copyright (c) 2017, Cswl Coldwind (cswl1337@gmail.com)
## This work is licensed under a Creative Commons Attribution 4.0 International License 
## http://creativecommons.org/licenses/by/4.0/

## Fast kernel building than `mka kernel`
## Uses ccache and tmpdir for maximum speed

# This script should be called from source top
BUILD_TOP="$(pwd)"

KERNEL_SRC="$BUILD_TOP/$FAST_KBUILD_SRC"
KERNEL_ARCH="$FAST_KBUILD_ARCH"
KERNEL_IMAGE="$FAST_KBUILD_IMAGE"

TMPDIR="/tmp/fst-kbuild.e003b"
CCACHE_BIN="$(which ccache)"

KERNEL_OUT="$TMPDIR/KERNEL_OUT/"
KERNEL_CROSS_COMPILE="$CCACHE_BIN $KERNEL_TOOLCHAIN/$KERNEL_TOOLCHAIN_PREFIX"
KERNEL_BUILT="$KERNEL_OUT/arch/arm/boot/$KERNEL_IMAGE"
KERNEL_CONFIG="$KERNEL_OUT/.config"
MAKE_FLAGS="CFLAGS_MODULE=-fno-pic"

export CCACHE_DIR="$TMPDIR/ccache"

setup_tmpdir(){
	mkdir -p "$TMPDIR"
	[[ ! -d "$TMPDIR/KERNEL_OUT" ]] && mkdir "$TMPDIR/KERNEL_OUT";
	[[ ! -d "$TMPDIR/ccache" ]] && mkdir "$TMPDIR/ccache";
	[[ ! -d "$TMPDIR/modules" ]] && mkdir "$TMPDIR/modules";
}

kernel_config() {
	echo "Building Kernel Config"
	make "$MAKE_FLAGS" -C "$KERNEL_SRC" O="$KERNEL_OUT" ARCH="$KERNEL_ARCH" CROSS_COMPILE="$KERNEL_CROSS_COMPILE" "$FAST_KBUILD_CONFIG"
}

kernel_menuconfig(){
	make "$MAKE_FLAGS" -C "$KERNEL_SRC" O="$KERNEL_OUT" ARCH="$KERNEL_ARCH" CROSS_COMPILE="$KERNEL_CROSS_COMPILE" menuconfig
}

kernel_image() {
	echo "Building Kernel"
	make "$MAKE_FLAGS" -C "$KERNEL_SRC" O="$KERNEL_OUT" ARCH="$KERNEL_ARCH" CROSS_COMPILE="$KERNEL_CROSS_COMPILE" "$KERNEL_IMAGE"
	if grep -q 'CONFIG_MODULES=y' "$KERNEL_CONFIG"; then
		kernel_modules
	fi;
}

kernel_modules() {
	echo "Building Kenrel modules."
	make "$MAKE_FLAGS" -C "$KERNEL_SRC" O="$KERNEL_OUT" ARCH="$KERNEL_ARCH" CROSS_COMPILE="$KERNEL_CROSS_COMPILE" modules

}

# Copy to tmpdir
kernel_copy() {
	cp "$KERNEL_BUILT" "$TMPDIR"
	if grep -q 'CONFIG_MODULES=y' "$KERNEL_CONFIG"; then
		kernel_copy_modules
	fi;
}

kernel_copy_modules() {
	find "$KERNEL_OUT" \
      -not \( -path ./Documentation -prune \) \
      -not \( -path ./include -prune \) \
      -not \( -path ./Kbuild -prune \) \
      -name \*.ko \
      -exec cp '{}' "$TMPDIR/modules/" ';'
}


case "$1" in 
	menuconfig)
		kernel_config
		kernel_menuconfig
	;;
	modules)
		kernel_modules
		kernel_copy_modules
	;;
	*)
		setup_tmpdir
		kernel_config
		kernel_image
		kernel_copy
	;;
esac