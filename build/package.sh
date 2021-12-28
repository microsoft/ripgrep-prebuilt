#!/bin/bash
# Adapted from https://github.com/BurntSushi/ripgrep/blob/master/ci/before_deploy.sh

# package the build artifacts

set -ex

. "$(dirname $0)/utils.sh"

mk_tarball() {
    pushd ..
    this_tag=`git tag -l --contains HEAD`
    popd
    local name="ripgrep-${this_tag}-${TARGET}.tar.gz"
    # When cross-compiling, use the right `strip` tool on the binary.
    local gcc_prefix="$(gcc_prefix)"
    
    # Copy the ripgrep binary and strip it.
    "${gcc_prefix}strip" "target/$TARGET/release/rg"

    tar czvf "$OUT_DIR/$name" -C ./target/$TARGET/release rg
    echo "##vso[task.setvariable variable=Name]$name"
}

main() {
    mk_tarball
}

main