#!/bin/bash
# Adapted from https://github.com/BurntSushi/ripgrep/blob/master/ci/script.sh

# build, test and generate docs in this phase

set -ex

. "$(dirname $0)/utils.sh"

main() {
    CARGO="$(builder)"

    ls -l /usr/local/opt
    ls -l /usr/local/opt/pcre2
    ls -l /usr/local/opt/pcre2/lib/libpcre2-8.0.dylib

    # Test a normal debug build.
    if is_arm || is_aarch64; then
        "$CARGO" build --target "$TARGET" --release
    else
        # Technically, MUSL builds will force PCRE2 to get statically compiled,
        # but we also want PCRE2 statically build for macOS binaries.
        PCRE2_SYS_STATIC=1 "$CARGO" build --target "$TARGET" --release --features 'pcre2'
    fi

    # Show the output of the most recent build.rs stderr.
    set +x
    stderr="$(find "target/$TARGET/release" -name stderr -print0 | xargs -0 ls -t | head -n1)"
    if [ -s "$stderr" ]; then
      echo "===== $stderr ====="
      cat "$stderr"
      echo "====="
    fi
    set -x

    # sanity check the file type
    file target/"$TARGET"/release/rg

    # Apparently tests don't work on arm, so just bail now. I guess we provide
    # ARM releases on a best effort basis?
    if is_arm || is_aarch64; then
      return 0
    fi

    # Run tests for ripgrep and all sub-crates.
    PCRE2_SYS_STATIC=1 "$CARGO" test --target "$TARGET" --release --verbose --all --features 'pcre2'
}

main