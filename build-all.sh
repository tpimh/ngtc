#!/bin/sh

ROOT='alpine'
REPO='http://dl-cdn.alpinelinux.org/alpine/edge/main'
DM='curl -Sq --progress-bar -O'

export LANG='C'

stage1 () {
  rm -rf $ROOT
  mkdir -p $ROOT
  $DM $REPO/x86_64/APKINDEX.tar.gz
  tar xf APKINDEX.tar.gz APKINDEX
  APKVER=$(grep -A1 -e 'P:apk-tools-static' APKINDEX | sed -n 's/V:\(.*\)/\1/p')
  $DM $REPO/x86_64/apk-tools-static-$APKVER.apk
  tar xf apk-tools-static-$APKVER.apk -C root sbin/apk.static 2>/dev/null
  rm apk-tools-static-$APKVER.apk APKINDEX.tar.gz APKINDEX
  cp -r root/* $ROOT

  ./proot -S $ROOT /sbin/apk.static -X $REPO -U --no-cache --allow-untrusted --initdb add alpine-base
  ./proot -S $ROOT /bin/sh -c "echo $REPO > /etc/apk/repositories"
  ./proot -S $ROOT /sbin/apk --no-cache add -t .llvmdeps git patch make cmake ninja clang-static clang-dev linux-headers g++ python
  ./proot -S $ROOT /usr/bin/env -i /bin/sh -l /sync.sh
  ./proot -S $ROOT /usr/bin/env -i /bin/sh -l /configure.sh
}
stage2 () {
  ./proot -S $ROOT /usr/bin/env -i /bin/sh -l /build.sh
}
stage3 () {
  ./proot -S $ROOT /usr/bin/env -i /bin/sh -l /install.sh
  mv $ROOT/*-pc-linux-musl.tar.gz .
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
