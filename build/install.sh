#!/bin/bash
# Adapted from https://github.com/BurntSushi/ripgrep/blob/master/ci/install.sh

# install stuff needed for the `script` phase

# Where rustup gets installed.
export PATH="$PATH:$HOME/.cargo/bin"

set -ex

. "$(dirname $0)/utils.sh"

install_rustup() {
    curl https://sh.rustup.rs -sSf \
      | sh -s -- -y --default-toolchain="$RUST_VERSION"

    # Linux
    if [ -f /usr/local/cargo/env ]; then
        source /usr/local/cargo/env
    fi

    # Mac
    if [ -f $HOME/.cargo/env ]; then
        source $HOME/.cargo/env
    fi

    rustup default $RUST_VERSION
    rustc -V
    cargo -V
}

install_targets() {
    if [[ $(host) != "$TARGET" ]]; then
        rustup target add $TARGET
    fi
}

install_osx_dependencies() {
    if ! is_osx; then
      return
    fi

    brew install asciidoc docbook-xsl
}

install_linux_dependencies() {
    if ! is_linux; then
        return
    fi
    sudo apt-get update
    sudo apt-get install -y musl-tools

    if is_arm; then
        sudo apt-get install gcc-arm-linux-gnueabihf
        sudo apt-get install binutils-arm-linux-gnueabihf
        sudo apt-get install libc6-armhf-cross
        sudo apt-get install libc6-dev-armhf-cross
    fi

    if is_aarch64; then
        sudo apt-get install gcc-aarch64-linux-gnu
    fi

    if is_ppc64le; then
        sudo apt-get install -y gcc-powerpc64le-linux-gnu
    fi

    if is_s390x; then
        sudo apt-get install -y gcc-s390x-linux-gnu
    fi
}

configure_cargo() {
    local prefix=$(gcc_prefix)
    if [ -n "${prefix}" ]; then
        local gcc="${prefix}gcc"

        # information about the cross compiler
        "${gcc}" -v

        # tell cargo which linker to use for cross compilation
        mkdir -p .cargo
        cat >> .cargo/config <<EOF
[target.$TARGET]
linker = "${gcc}"
EOF
    fi
        cat >> Cargo.toml <<EOF
[profile.release]
debug = false
strip = true
EOF
cat Cargo.toml
}

main() {
    printenv

    install_linux_dependencies
    install_osx_dependencies
    install_rustup
    install_targets
    configure_cargo
}

main
