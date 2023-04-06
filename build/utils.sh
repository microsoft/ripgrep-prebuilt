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
        arm*-unknown-linux-musleabihf)
            echo armhf-musl
            ;;
        aarch64-unknown-linux-gnu)
            echo aarch64
            ;;
        aarch64-unknown-linux-musl)
            echo aarch64-musl
            ;;
        aarch64-apple-darwin)
            echo arm64
            ;;
        powerpc64le-unknown-linux-gnu)
            echo ppc64le
            ;;
        s390x-unknown-linux-gnu)
            echo s390x
            ;;
        *)
            die "architecture: unexpected target $TARGET"
            ;;
    esac
}

gcc_prefix() {
    case "$(architecture)" in
        armhf)
            echo arm-linux-musleabihf-
            ;;
        aarch64)
            echo aarch64-linux-gnu-
            ;;
        ppc64le)
            echo  powerpc64le-linux-gnu-
	        ;;
        s390x)
            echo s390x-linux-gnu-
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

is_arm_musl() {
    case "$(architecture)" in
        armhf-musl) return 0 ;;
        *)     return 1 ;;
    esac
}

is_aarch64() {
    case "$(architecture)" in
        aarch64) return 0 ;;
        *)     return 1 ;;
    esac
}

is_aarch64_musl() {
    case "$(architecture)" in
        aarch64-musl) return 0 ;;
        *)     return 1 ;;
    esac
}

is_arm64() {
    case "$(architecture)" in
        arm64) return 0 ;;
        *)     return 1 ;;
    esac
}

is_ppc64le() {
    case "$(architecture)" in
        ppc64le) return 0 ;;
        *)       return 1 ;;
    esac
}	

is_s390x() {
    case "$(architecture)" in
        s390x) return 0 ;;
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
    if is_musl && is_aarch64_musl; then
        cargo install cross --version 0.2.1
        echo "cross"
    else
        echo "cargo"
    fi
}
