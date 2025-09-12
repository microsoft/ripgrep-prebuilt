# Contributing to ripgrep-prebuilt

- Developing
  - Requirements
  - Patching

## Developing

### Requirements

- [Rust](https://www.rust-lang.org/tools/install)

### Patching

This section is for ripgrep-prebuilt repository maintainers.

When adjusting the version of ripgrep referenced in config.json, you may have to refresh the patch file so that it can be cleanly applied to the new version.
One way to refresh the patch file is the following:

1. Check out the upstream repository indicated by `ripgrepRepo`, which is currently `BurntSushi/ripgrep`, and checkout the tag indicated by `ripgrepTag`, such as `14.1.1`.
2. Manually reapply the `Cargo.toml` changes within the patch file to the upstream repository.
3. Run `cargo build` to update the upstream repository's `Cargo.lock` file.
4. Manually reapply the `.cargo/config.toml` changes within the patch file to the upstream repository.
5. Modify the upstream repository more as needed, leaving the files unstaged.
6. Run `git diff > new-patch.patch` in the upstream repository to save all of these changes to a new patch file.
7. Replace the contents of the current patch file with the contents of the new patch file.
