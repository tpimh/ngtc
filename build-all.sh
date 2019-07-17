#!/bin/sh

ARCH='x86_64'

export LANG='C'

stage1 () {
  rm -rf root/src root/build
  apk add -t .llvmdeps git patch make cmake ninja clang-static clang-dev linux-headers g++ python libexecinfo-dev
  root/sync.sh
  root/configure.sh
}
stage2 () {
  root/build.sh
}
stage3 () {
  root/install.sh
  mv /*-pc-linux-musl.tar.gz .
}

case $1 in
  configure)
    stage1
    exit
    ;;
  build)
    stage2
    exit
    ;;
  install)
    stage3
    exit
    ;;  
  *)
    stage1
    stage2
    stage3
    exit
    ;;
esac
