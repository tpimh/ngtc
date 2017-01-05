# NGTC
Non-GNU toolchain

## Building

Requirements: C++ compiler, `git`, `cmake` 3.5, `ninja`, `make`, 64bit Linux distro, at least 6Gb of RAM and a lot of time.

Instructions: run `./build-all.sh`, this will build x86_64 musl-based toolchain and a simple helloworld application.

## What is included

- `musl` libc
- `clang` compiler
- `lld` linker

## What is not included

- Any code from glibc
- Any code from gcc or libgcc
- Any code from GNU binutils

## What works

- Most applications written in C can be built with NGTC

## What doesn't work

- C++ apps can't be built with NGTC (yet)
- Linux kernel can't be built with NGTC (yet)

## Status

### Platform support

- x86_64

### Language support

- C
