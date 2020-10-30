#!/bin/bash

set -ex

REPO='BurntSushi/ripgrep'
TREEISH='12.1.1'
THIS_TAG=`git tag -l --contains HEAD`

cd ~
git clone https://github.com/${REPO}.git
cd ripgrep
git checkout $TREEISH

TARGET="s390x-unknown-linux-gnu"
cargo build --release --target=$TARGET
strip ./target/${TARGET}/release/rg
tar czvf "ripgrep-${THIS_TAG}-${TARGET}.tar.gz" -C ./target/${TARGET}/release/ rg
target/${TARGET}/release/rg --version
