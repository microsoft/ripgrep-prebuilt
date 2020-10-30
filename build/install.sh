#!/bin/bash
# Adapted from https://github.com/BurntSushi/ripgrep/blob/master/ci/install.sh

# install stuff needed for the `script` phase

# Where rustup gets installed.
export PATH="$PATH:$HOME/.cargo/bin"

set -ex

. "$(dirname $0)/utils.sh"

install_rustup() {
    if is_osx && is_arm64; then
        arch --x86_64 sh <(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs) \
            -y --default-host "$TARGET" --default-toolchain "$RUST_VERSION"
    else
        curl https://sh.rustup.rs -sSf \
            | sh -s -- -y --default-toolchain="$RUST_VERSION"
    fi

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
    if [ $(host) != "$TARGET" ]; then
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
        sudo apt-get install gcc-4.8-arm-linux-gnueabihf
        sudo apt-get install gcc-arm-linux-gnueabihf
        sudo apt-get install binutils-arm-linux-gnueabihf
        sudo apt-get install libc6-armhf-cross
        sudo apt-get install libc6-dev-armhf-cross
    fi

    if is_aarch64; then
        sudo apt-get install gcc-4.8-aarch64-linux-gnu
    fi
}

configure_cargo() {
    local prefix=$(gcc_prefix)
    if [ -n "${prefix}" ]; then
        local gcc_suffix=
        if [ -n "$GCC_VERSION" ]; then
          gcc_suffix="-$GCC_VERSION"
        fi
        local gcc="${prefix}gcc${gcc_suffix}"

        # information about the cross compiler
        "${gcc}" -v

        # tell cargo which linker to use for cross compilation
        mkdir -p .cargo
        cat >> .cargo/config <<EOF
[target.$TARGET]
linker = "${gcc}"
EOF
    fi
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