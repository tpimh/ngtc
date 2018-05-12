#!/bin/sh

ROOT='alpine'
REPO='http://dl-cdn.alpinelinux.org/alpine/edge/main'
APKVER='2.9.1-r3'

rm -rf $ROOT
mkdir -p $ROOT
wget $REPO/x86_64/apk-tools-static-$APKVER.apk
tar xf apk-tools-static-$APKVER.apk -C root sbin/apk.static 2>/dev/null
rm apk-tools-static-$APKVER.apk
cp -r root/* $ROOT

./proot -S $ROOT /sbin/apk.static -X $REPO -U --no-cache --allow-untrusted --initdb add alpine-base
./proot -S $ROOT /bin/sh -c "echo $REPO > /etc/apk/repositories"
./proot -S $ROOT /sbin/apk --no-cache add -t .llvmdeps git patch make cmake ninja clang-static clang-dev linux-headers g++ python
./proot -S $ROOT /usr/bin/env -i /bin/sh -l /sync.sh
./proot -S $ROOT /usr/bin/env -i /bin/sh -l /configure.sh
./proot -S $ROOT /usr/bin/env -i /bin/sh -l /build.sh
./proot -S $ROOT /usr/bin/env -i /bin/sh -l /install.sh

mv $ROOT/*-pc-linux-musl.tar.gz .
