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

ninja install || exit 42

cd /"$ARCH"-pc-linux-musl/bin || $(echo 'failed to change directory' && exit 1)
ln -s llvm-ar ar
ln -s llvm-ranlib ranlib
ln -s llvm-objcopy objcopy
ln -s llvm-objcopy strip
ln -s clang cc
ln -s clang++ c++
ln -s ld.lld ld
cd / || $(echo 'failed to change directory' && exit 1)
tar cvfz "$ARCH"-pc-linux-musl.tar.gz "$ARCH"-pc-linux-musl || exit 46
