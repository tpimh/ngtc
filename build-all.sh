#!/bin/sh

DIR="$(dirname "$(readlink -f "$0")")"
ARCH="x86_64"
TARGETS="X86"

cd "$DIR"/src
git clone https://github.com/llvm-mirror/llvm
git clone https://github.com/llvm-mirror/clang
git clone https://github.com/llvm-mirror/lld
git clone https://github.com/llvm-mirror/libunwind
git clone https://github.com/llvm-mirror/compiler-rt
git clone https://github.com/llvm-mirror/libcxx
git clone https://github.com/llvm-mirror/libcxxabi

cd llvm/tools
ln -s ../../clang clang
ln -s ../../lld lld
cd ../projects
ln -s ../../libunwind libunwind
ln -s ../../compiler-rt compiler-rt
ln -s ../../libcxx libcxx
ln -s ../../libcxxabi libcxxabi

mkdir ../build
cd ../build

cmake \
    -DCLANG_DEFAULT_CXX_STDLIB=libc++ \
    -DCLANG_DEFAULT_LINKER=lld \
    -DCLANG_DEFAULT_RTLIB=compiler-rt \
    -DLLVM_DEFAULT_TARGET_TRIPLE="$ARCH"-pc-linux-musl \
    -DDEFAULT_SYSROOT="$DIR"/"$ARCH"-pc-linux-musl/musl \
    -DGCC_INSTALL_PREFIX="$DIR"/"$ARCH"-pc-linux-musl/gcc-stub \
    -DCMAKE_INSTALL_PREFIX="$DIR"/"$ARCH"-pc-linux-musl/llvm \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_TARGETS_TO_BUILD="$TARGETS" \
    -G Ninja ..
ninja
ninja install

PATH="$DIR"/"$ARCH"-pc-linux-musl/llvm/bin:"$PATH"

cd ../..
git clone git://git.musl-libc.org/musl

mkdir musl/build
cd musl
for PATCH in "$DIR"/patches/*-musl.patch; do
  patch -p1 < $PATCH
done
cd build

../configure \
    CC='clang'
    LIBCC="$DIR"/"$ARCH"-pc-linux-musl/llvm/lib/clang/4.0.0/lib/linux/libclang_rt.builtins-"$ARCH".a \
    --prefix="$DIR"/"$ARCH"-pc-linux-musl/musl \
    --syslibdir="$DIR"/"$ARCH"-pc-linux-musl/musl/lib
make
make install

cd ../../startup
make ARCH="$ARCH"
make install ARCH="$ARCH" DESTDIR="$DIR"/"$ARCH"-pc-linux-musl/musl/lib

cd ../hello
clang -o hello hello.c
"$DIR"/"$ARCH"-pc-linux-musl/musl/lib/ld-musl-"$ARCH".so.1 ./hello
