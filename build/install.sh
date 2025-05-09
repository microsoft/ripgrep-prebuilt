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
    installer='apt-get'
    if [ "${USE_MARINER}" = 'true' ]; then
        installer='tdnf'
    fi
    sudo "${installer}" update
    sudo "${installer}" install -y musl-tools

    if is_arm; then
        sudo "${installer}" install -y gcc-arm-linux-gnueabihf
        sudo "${installer}" install -y binutils-arm-linux-gnueabihf
        sudo "${installer}" install -y libc6-armhf-cross
        sudo "${installer}" install -y libc6-dev-armhf-cross
    fi

    if is_aarch64; then
        sudo "${installer}" install -y gcc-aarch64-linux-gnu
    fi

    if is_ppc64le; then
        sudo "${installer}" install -y gcc-powerpc64le-linux-gnu
    fi

    if is_s390x; then
        sudo "${installer}" install -y gcc-s390x-linux-gnu
    fi
}

configure_cargo() {
    local prefix=$(gcc_prefix)

    if [ -n "${prefix}" ]; then
        local gcc="${prefix}gcc"

        # information about the cross compiler
        "${gcc}" -v

        mkdir -p .cargo

        # tell cargo which linker to use for cross compilation
        cat >> .cargo/config <<EOF
[target.$TARGET]
linker = "${gcc}"
EOF
    fi
    
    override_debug

    cat >> ripgrep/.cargo/config <<EOF

[profile.release] # release flags https://doc.rust-lang.org/cargo/reference/profiles.html#release
strip = true # removes debug symbols
lto = true # enables link time optimization
codegen-units = 1 # makes it link in a single progress, where it normally runs in multiple independent workers in parallel. Might make compilation a little slower
EOF
}

override_debug() {
    # remove debug builds
    # Uses the env variable to set the debug flag because cargo builds that use cross can only use configs that are within the ripgrep dir
    # and their Cargo.toml already sets debug=1 https://github.com/BurntSushi/ripgrep/blob/61101289fabc032fd8e90009c41d0b78e6dfc9a2/Cargo.toml#L87
    export CARGO_PROFILE_RELEASE_DEBUG=0  
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
