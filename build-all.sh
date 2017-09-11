#!/bin/sh

ROOT='alpine'
REPO='http://dl-cdn.alpinelinux.org/alpine/edge/main'

rm -rf $ROOT
mkdir -p $ROOT
cp -r apk.static sync.sh build.sh patch $ROOT

./proot -S $ROOT /apk.static -X $REPO -U --no-cache --allow-untrusted --initdb add alpine-base
./proot -S $ROOT /bin/sh -c "echo $REPO > /etc/apk/repositories"
./proot -S alpine /apk.static --no-cache add -t .llvmdeps git patch make cmake ninja clang-static clang-dev linux-headers g++ python
./proot -S alpine /usr/bin/env -i /bin/sh -l /sync.sh
./proot -S alpine /usr/bin/env -i /bin/sh -l /build.sh
