#!/bin/sh

TOOLS='clang lld'
PROJECTS='libunwind compiler-rt libcxx libcxxabi'
ARCH="$(uname -m)"
TARGETS='X86'
ROOT=$(dirname $(readlink -f "$0"))

PATH=/"$ARCH"-pc-linux-musl/bin:"$PATH"
LD_LIBRARY_PATH=/"$ARCH"-pc-linux-musl/lib

if [ ! -d $ROOT/src ]; then
  echo no sources found, run sync
  exit 1
fi

if [ ! -d $ROOT/build ]; then
  mkdir $ROOT/build || $(echo 'failed to create directory' && exit 1)
fi

cd $ROOT/build || $(echo 'failed to change directory' && exit 1)

for TOOL in $TOOLS; do
  if [ ! -e $ROOT/src/llvm/tools/$TOOL ]; then
    ln -s $ROOT/src/$TOOL $ROOT/src/llvm/tools/$TOOL
  fi
done

for PRJ in $PROJECTS; do
  if [ ! -e $ROOT/src/llvm/projects/$PRJ ]; then
    ln -s $ROOT/src/$PRJ $ROOT/src/llvm/projects/$PRJ
  fi
done

if [ ! -d $ROOT/build/llvm ]; then
  mkdir $ROOT/build/llvm || $(echo 'failed to create directory' && exit 1)
fi

cd $ROOT/build/llvm || $(echo 'failed to change directory' && exit 1)

ninja || exit 41
