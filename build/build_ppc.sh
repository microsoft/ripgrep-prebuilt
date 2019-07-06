#!/bin/bash

set -ex

REPO=$(node -p "require('./config.json').ripgrepRepo")
TREEISH=$(node -p "require('./config.json').ripgrepTag")
THIS_TAG=`git tag -l --contains HEAD`

cd ~
git clone https://github.com/${REPO}.git
cd ripgrep
git checkout $TREEISH

TARGET="powerpc64le-unknown-linux-gnu"
cargo build --release --target=$TARGET --features 'pcre2'
strip ./target/${TARGET}/release/rg
zip -j "ripgrep-${THIS_TAG}-${TARGET}.zip" ./target/${TARGET}/release/rg
target/${TARGET}/release/rg --version
