#!/bin/sh

REPOS='llvm clang lld libunwind compiler-rt libcxx libcxxabi'
ROOT=$(dirname $(readlink -f "$0"))
VERSION="11.0.0"
BASEURL="https://github.com/llvm/llvm-project/releases/download/llvmorg-$VERSION/"

if [ ! -d $ROOT/src ]; then
  mkdir $ROOT/src || $(echo 'failed to create directory' && exit 1)
fi

cd $ROOT/src || $(echo 'failed to change directory' && exit 1)

for REPO in $REPOS; do
  if [ ! -d $REPO ]; then
    DIRNAME="$REPO-$VERSION.src"
    FILENAME="$DIRNAME.tar.xz"
    wget $BASEURL/$FILENAME
    tar xf $FILENAME
    mv $DIRNAME $REPO
    rm $FILENAME
  else
    echo "directory $REPO already exists" && exit 1
  fi
done

for REPO in $REPOS; do
  PATCHES="$(ls -1 $ROOT/patch/$REPO-*.patch 2>/dev/null)"
  NUMPATCHES="$(ls -1 $ROOT/patch/$REPO-*.patch 2>/dev/null | wc -l)"
  NUMPATCH=0
  for PATCH in $PATCHES; do
    NUMPATCH=$(($NUMPATCH+1))
    echo -n "patching $REPO ($NUMPATCH/$NUMPATCHES)... "
    if ! patch -p1 --dry-run -s -f -d $ROOT/src/$REPO -i $PATCH >/dev/null; then
      echo fail
    else
      patch -p1 -s -f -d $ROOT/src/$REPO -i $PATCH >/dev/null
      echo success
    fi
  done
done
