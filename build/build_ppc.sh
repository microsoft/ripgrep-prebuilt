#!/bin/bash

set -ex

cd ~
REPO=$(node -p "require('./config.json').ripgrepRepo")
TREEISH=$(node -p "require('./config.json').ripgrepTag")
git clone https://github.com/${REPO}.git
cd ripgrep
git checkout $TREEISH
cargo build --release --target=powerpc64le-unknown-linux-gnu --features 'pcre2'
strip ./target/powerpc64le-unknown-linux-gnu/release/rg
zip -j "ripgrep-linux-ppc64le.zip" ./target/powerpc64le-unknown-linux-gnu/release/rg
target/powerpc64le-unknown-linux-gnu/release/rg --version

