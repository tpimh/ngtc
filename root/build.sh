#!/bin/sh

TOOLS='clang lld'
PROJECTS='libunwind compiler-rt libcxx libcxxabi'
ARCH="$(uname -m)"
TARGETS='X86'

PATH=/"$ARCH"-pc-linux-musl/bin:"$PATH"
LD_LIBRARY_PATH=/"$ARCH"-pc-linux-musl/lib

if [ ! -d /src ]; then
  echo no sources found, run sync
  exit 1
fi

if [ ! -d /build ]; then
  mkdir /build || $(echo 'failed to create directory' && exit 1)
fi

cd /build || $(echo 'failed to change directory' && exit 1)

for TOOL in $TOOLS; do
  if [ ! -e /src/llvm/tools/$TOOL ]; then
    ln -s /src/$TOOL /src/llvm/tools/$TOOL
  fi
done

for PRJ in $PROJECTS; do
  if [ ! -e /src/llvm/projects/$PRJ ]; then
    ln -s /src/$PRJ /src/llvm/projects/$PRJ
  fi
done

if [ ! -d /build/llvm ]; then
  mkdir /build/llvm || $(echo 'failed to create directory' && exit 1)
fi

cd /build/llvm || $(echo 'failed to change directory' && exit 1)

cmake \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DLIBCXXABI_LIBCXX_PATH=/src/libcxx \
    -DLIBCXXABI_LIBCXX_INCLUDES=/src/libcxx/include \
    -DLIBCXXABI_ENABLE_STATIC_UNWINDER=ON \
    -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
    -DLIBCXX_LIBCXXABI_INCLUDES_INTERNAL=/src/libcxxabi/include \
    -DLIBCXX_HAS_MUSL_LIBC=ON \
    -DLIBCXX_HAS_GCC_S_LIB=OFF \
    -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
    -DLIBUNWIND_ENABLE_SHARED=OFF \
    -DCLANG_DEFAULT_CXX_STDLIB=libc++ \
    -DCLANG_DEFAULT_LINKER=lld \
    -DCLANG_DEFAULT_RTLIB=compiler-rt \
    -DLLVM_DEFAULT_TARGET_TRIPLE="$ARCH"-pc-linux-musl \
    -DDEFAULT_SYSROOT=/"$ARCH"-pc-linux-musl \
    -DCMAKE_INSTALL_PREFIX=/"$ARCH"-pc-linux-musl \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_TARGET_ARCH="$ARCH" \
    -DLLVM_TARGETS_TO_BUILD="$TARGETS" \
    -G Ninja \
    /src/llvm || exit 40
ninja -j1 || exit 41
ninja install || exit 42

if [ ! -d /build/musl ]; then
  mkdir /build/musl || $(echo 'failed to create directory' && exit 1)
fi

cd /build/musl || $(echo 'failed to change directory' && exit 1)

/src/musl/configure \
    LIBCC="$(clang -print-libgcc-file-name)" \
    CC='clang' \
    --prefix=/"$ARCH"-pc-linux-musl \
    --syslibdir=/"$ARCH"-pc-linux-musl/lib || exit 43
make || exit 44
make install || exit 45
