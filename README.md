# GetPatched Poppler recipe

This public recipe pins Ubuntu 20.04 Focal's freely available Poppler source and carries a target-specific backport for CVE-2025-52885. The affected path is reached by `pdfinfo -struct` while parsing a malformed PDF structure tree. The issue is a local user-triggered use-after-free; this repository makes no claim of remote exploitation.

## Target

| Target | Distro source | Candidate version | CVE | Status |
|---|---|---|---|---|
| Ubuntu Focal amd64 | `0.86.1-0ubuntu1.7` | `0.86.1-0ubuntu1.7+getpatched1` | CVE-2025-52885 | Development candidate; distro package checks pending |

Debian Bullseye, Bookworm, and Trixie are excluded because their public packages are fixed. Ubuntu's Focal ESM source is not used. The Focal source descriptor and both archives are pinned by SHA-256 in `targets/ubuntu/focal-amd64.json`; hashes were checked against the signed Ubuntu source index. The uploader signature on the `.dsc` has not been separately verified.

## Backport

`patches/CVE-2025-52885-focal.patch` is a context-adjusted backport of upstream commit [`4ce27cc826bf90cc8dbbd8a8c87bd913cccd7ec0`](https://gitlab.freedesktop.org/poppler/poppler/-/commit/4ce27cc826bf90cc8dbbd8a8c87bd913cccd7ec0). It rejects a duplicate number-tree key before resizing its parent vector, preventing stale pointers retained by `refToParentMap`. The upstream patch did not apply verbatim because Poppler 0.86.1 uses different indentation and spacing; the port adds a four-line guard at the corresponding location.

The output preserves Ubuntu's source version and appends `+getpatched1`. Later patches on the same source increment the serial; changed distro source requires a separately pinned target and fresh tests.

## Regression evidence and limits

The regression fixture is GitHub Security Lab's public `bug.pdf`, copied from `SecurityExploits/freedesktop/poppler-CVE-2025-52885` at Git blob `57b7c92aa4442c21aa570ab0de190ba2f4aa0827`. It is MIT-licensed; the license and attribution are retained in `LICENSES/` and `tests/fixtures/README.md`.

On pristine Ubuntu Focal source version `0.86.1-0ubuntu1.7`'s upstream 0.86.1 code, a native AddressSanitizer source build aborts on `pdfinfo -struct bug.pdf` with `heap-use-after-free` in `StructTreeRoot::parentTreeAdd`. The same source build with this backport exits successfully without an AddressSanitizer error. Raw logs and the fixture checksum are recorded in the GetPatched platform repository under `evidence/poppler-cve-2025-52885-source-regression-20261030/`.

This is source-level evidence from macOS/AppleClang, not an Ubuntu `.deb` build or installed-package result. The candidate is not release-ready until the hosted Ubuntu build, installed baseline/patched regression, package-aware before/after scan, normal consumer checks, and fresh signed APT client tests pass.

The platform's installed-package regression runner uses Valgrind Memcheck, not AddressSanitizer: it requires the exact baseline package to report the `StructTreeRoot::parentTreeAdd` invalid access and the patched package to complete with zero Memcheck errors. The native macOS ASan logs above are separate source-level evidence.

The target lists all binary packages produced by the Ubuntu source package so ABI-coupled libraries and their consumers remain version-aligned. No package binaries are published by this recipe.

## Licensing

The MIT license in `LICENSE` applies only to original GetPatched-authored recipe metadata, tests, and documentation. The security patch is a context-adjusted port of Poppler code and is identified as `GPL-2.0-only` in `package-manifest.json` and `patches/metadata.json`; it is not relicensed under MIT. The PoC retains its upstream MIT license. Poppler and Ubuntu copyright/license notices are preserved in `LICENSES/`; preserve upstream and distribution obligations in every source and binary package.
