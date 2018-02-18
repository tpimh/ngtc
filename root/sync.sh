#!/bin/sh

LLVMREPO='https://git.llvm.org/git'
MUSLREPO='git://git.musl-libc.org/musl'
REPOS='llvm clang lld libunwind compiler-rt libcxx libcxxabi musl'

clonerepo () {
  echo -n "cloning $1... ";

  if [ "$1" = "musl" ]; then 
    REPO="$MUSLREPO"
  else
    REPO="$LLVMREPO/$1/"
  fi

  if ! git clone --depth 1 $REPO &>/dev/null; then
    echo fail
    rm -rf $1
    exit 2
  else
    echo success
  fi
}

pullrepo () {
  echo -n "updating $1... "

  if [ "$1" = "musl" ]; then 
    REPO="$MUSLREPO"
  else
    REPO="$LLVMREPO/$1/"
  fi

  if ! git -C $1 pull &>/dev/null; then
    echo fail
    rm -rf $1
    clonerepo $1
  else
    echo success
  fi
}

if [ ! -d /src ]; then
  mkdir /src || $(echo 'failed to create directory' && exit 1)
else
  for REPO in $REPOS; do
    PATCHES="$(ls -r -1 /patch/$REPO-*.patch 2>/dev/null)"
    NUMPATCHES="$(ls -r -1 /patch/$REPO-*.patch 2>/dev/null | wc -l)"
    NUMPATCH=0
    for PATCH in $PATCHES; do
      NUMPATCH=$(($NUMPATCH+1))
      echo -n "unpatching $REPO ($NUMPATCH/$NUMPATCHES)... "
      if ! patch -R -p1 --dry-run -s -f -d /src/$REPO -i $PATCH >/dev/null; then
        echo fail
      else
        patch -R -p1 -s -f -d /src/$REPO -i $PATCH >/dev/null
        echo success
      fi
    done
  done
fi

cd /src || $(echo 'failed to change directory' && exit 1)

for REPO in $REPOS; do
  if [ -d $REPO ]; then
    pullrepo $REPO
  else
    clonerepo $REPO
  fi
done

for REPO in $REPOS; do
  PATCHES="$(ls -1 /patch/$REPO-*.patch 2>/dev/null)"
  NUMPATCHES="$(ls -1 /patch/$REPO-*.patch 2>/dev/null | wc -l)"
  NUMPATCH=0
  for PATCH in $PATCHES; do
    NUMPATCH=$(($NUMPATCH+1))
    echo -n "patching $REPO ($NUMPATCH/$NUMPATCHES)... "
    if ! patch -p1 --dry-run -s -f -d /src/$REPO -i $PATCH >/dev/null; then
      echo fail
    else
      patch -p1 -s -f -d /src/$REPO -i $PATCH >/dev/null
      echo success
    fi
  done
done
