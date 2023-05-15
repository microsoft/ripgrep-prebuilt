#!/bin/bash
# Adapted from https://github.com/BurntSushi/ripgrep/blob/master/ci/script.sh

# build, test and generate docs in this phase

set -ex

. "$(dirname $0)/utils.sh"

main() {
    CARGO="$(builder)"

    ENV_VARS=""
    if is_linux && is_musl; then
        # jemalloc doesn't allow 16K page sizes for linux musl 
        # https://github.com/microsoft/ripgrep-prebuilt/issues/26
        ENV_VARS = "JEMALLOC_SYS_WITH_LG_PAGE=14"
    fi

    # Test a normal debug build.
    if is_arm || is_aarch64 || is_ppc64le; then
        $ENV_VARS "$CARGO" build --target "$TARGET" --release --features 'pcre2'
    # pcre2 is not supported on s390x
    # https://github.com/zherczeg/sljit/issues/89
    elif is_s390x; then
        $ENV_VARS "$CARGO" build --release --target=$TARGET
    else
        ENV_VARS = "PCRE2_SYS_STATIC=1 $ENV_VARS";
        # Technically, MUSL builds will force PCRE2 to get statically compiled,
        # but we also want PCRE2 statically build for macOS binaries.
        $ENV_VARS "$CARGO" build --target "$TARGET" --release --features 'pcre2'
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

    # Apparently tests don't work on arm, s390x and ppc64le so just bail now. I guess we provide
    # ARM, ppc64le and s390x releases on a best effort basis?
    if is_arm || is_aarch64 || is_arm64 || is_ppc64le || is_s390x; then
      return 0
    fi

    # Run tests for ripgrep and all sub-crates.
    PCRE2_SYS_STATIC=1 "$CARGO" test --target "$TARGET" --release --verbose --all --features 'pcre2'
}

main
