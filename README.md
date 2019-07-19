# NGTC

Non-GNU toolchain

The goal of this project is to build a toolchain that can build Linux kernel, a minimal userspace (e.g. [nenuzhnix](https://github.com/tpimh/nenuzhnix)) and ultimately itself without using any GNU software. 

## Building

Requirements: Docker, at least 6Gb of RAM and a lot of time.

Instructions: `docker run tpimh/ngtc:latest /bin/sh -c 'git clone https://github.com/tpimh/ngtc && cd ngtc && root/sync.sh && root/configure.sh && root/build.sh && root/install.sh'`

## What is included

- Clang
- compiler-rt
- libc++
- libc++abi
- libunwind
- LLD
- LLVM

## What is not included

- Any code from glibc
- Any code from gcc or libgcc
- Any code from GNU binutils

## What works

- C code compilation
- C++ code compilation

## Status

### Platform support

|  | x86  | ARM |
| --- | :---: | :---: |
| **32 bit**  |  |  |
| **64 bit**  | + |  |

- x86_64

### Language support

- C
- C++
- (not yet) Rust
- (not yet) Go
- (not yet) D
