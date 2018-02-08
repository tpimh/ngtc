# NGTC

Non-GNU toolchain

The goal of this project is to build a toolchain that can build Linux kernel, a minimal userspace (e.g. [nenuzhnix](https://github.com/tpimh/nenuzhnix)) and ultimately itself without using any GNU software. 

## Building

Requirements: x86_64 Linux distro with at least 6Gb of RAM and a lot of time.

Instructions: run `./build-all.sh`, this will set up the build environment, download toolchain source code and compile it.

## What is included

- `musl` libc
- `clang` compiler
- `lld` linker

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
