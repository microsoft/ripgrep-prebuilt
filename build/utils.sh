#!/bin/bash
# Adapted from https://github.com/BurntSushi/ripgrep/blob/master/ci/utils.sh

# Various utility functions used through CI.

if [ -f $HOME/.cargo/env ]; then
    source $HOME/.cargo/env
fi

host() {
    case "$AGENT_OS" in
        Linux)
            echo x86_64-unknown-linux-gnu
            ;;
        Darwin)
            echo x86_64-apple-darwin
            ;;
    esac
}

architecture() {
    case "$TARGET" in
        x86_64-*)
            echo amd64
            ;;
        i686-*|i586-*|i386-*)
            echo i386
            ;;
        arm*-unknown-linux-gnueabihf)
            echo armhf
            ;;
        aarch64-unknown-linux-gnu)
            echo aarch64
            ;;
        aarch64-apple-darwin)
            echo arm64
            ;;
        *)
            die "architecture: unexpected target $TARGET"
            ;;
    esac
}

gcc_prefix() {
    case "$(architecture)" in
        armhf)
            echo arm-linux-gnueabihf-
            ;;
        aarch64)
            echo aarch64-linux-gnu-
            ;;
        *)
            return
            ;;
    esac
}

is_musl() {
    case "$TARGET" in
        *-musl) return 0 ;;
        *)      return 1 ;;
    esac
}

is_x86() {
    case "$(architecture)" in
      amd64|i386) return 0 ;;
      *)          return 1 ;;
    esac
}

is_x86_64() {
    case "$(architecture)" in
      amd64) return 0 ;;
      *)          return 1 ;;
    esac
}

is_arm() {
    case "$(architecture)" in
        armhf) return 0 ;;
        *)     return 1 ;;
    esac
}

is_aarch64() {
    case "$(architecture)" in
        aarch64) return 0 ;;
        *)     return 1 ;;
    esac
}

is_arm64() {
    case "$(architecture)" in
        arm64) return 0 ;;
        *)     return 1 ;;
    esac
}

is_linux() {
    case "$AGENT_OS" in
        Linux) return 0 ;;
        *)     return 1 ;;
    esac
}

is_osx() {
    case "$AGENT_OS" in
        Darwin) return 0 ;;
        *)   return 1 ;;
    esac
}

builder() {
    if is_musl && is_x86_64; then
        # IMPORTANT - put this back when building anything past 11.0.1
        # set -u
        # D=$(mktemp -d)
        # git clone https://github.com/rust-embedded/cross.git "$D"
        # cd "$D"
        # curl -O -L "https://gist.githubusercontent.com/nickbabcock/c7bdc8e5974ed9956abf46ffd7dc13ff/raw/e211bc17ea88e505003ad763fac7060b4ac1d8d0/patch"
        # git apply patch
        # cargo install --path .
        # rm -rf "$D"
        # echo "cross"

        echo "cargo"
    else
        echo "cargo"
    fi
}