#!/bin/bash
# icecat-lite build script for GNU/Linux
set -e

# build dependencies (Debian/Trisquel-style systems):
apt-get update
aptitude -q -y build-dep firefox
cargo install cbindgen

ln -s /usr/lib/llvm*/bin/clang /bin/clang -f
ln -s /usr/lib/llvm*/bin/clang++ /bin/clang++ -f

cp ../data/buildscripts/mozconfig-common .mozconfig
cat ../data/buildscripts/mozconfig-gnulinux >> .mozconfig

rm -rf obj-gnulinux

./mach build
./mach package
