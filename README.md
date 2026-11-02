# GetPatched Poppler recipe

This public recipe pins freely available Ubuntu and Debian Poppler sources and carries target-specific security backports. It covers a malformed structure-tree use-after-free on Ubuntu Focal (CVE-2025-52885) and a revision 6 password-length overflow on Debian Bookworm and Trixie (CVE-2026-107705). Each source version and architecture is an independent build target; the Debian targets remain unverified development candidates until their installed-package regression and scan runs pass.

## Target

| Target | Distro source | Candidate version | CVE | Status |
|---|---|---|---|---|
| Ubuntu Focal amd64 | `0.86.1-0ubuntu1.7` | `0.86.1-0ubuntu1.7+getpatched1` | CVE-2025-52885 | Development candidate; distro package checks pending |
| Debian Bookworm amd64 | `22.12.0-2+deb12u2` | `22.12.0-2+deb12u2+getpatched1` | CVE-2026-107705 | Unverified development candidate |
| Debian Trixie amd64 | `25.03.0-5+deb13u4` | `25.03.0-5+deb13u4+getpatched1` | CVE-2026-107705 | Unverified development candidate |

For CVE-2025-52885, Debian Bullseye, Bookworm, and Trixie are excluded because their public packages are fixed; applicability is evaluated separately for each CVE. Ubuntu's Focal ESM source is not used. The Focal source descriptor and both archives are pinned by SHA-256 in `targets/ubuntu/focal-amd64.json`; hashes were checked against the signed Ubuntu source index. The uploader signature on the `.dsc` has not been separately verified.

## Backport

`patches/CVE-2025-52885-focal.patch` is a context-adjusted backport of upstream commit [`4ce27cc826bf90cc8dbbd8a8c87bd913cccd7ec0`](https://gitlab.freedesktop.org/poppler/poppler/-/commit/4ce27cc826bf90cc8dbbd8a8c87bd913cccd7ec0). It rejects a duplicate number-tree key before resizing its parent vector, preventing stale pointers retained by `refToParentMap`. The upstream patch did not apply verbatim because Poppler 0.86.1 uses different indentation and spacing; the port adds a four-line guard at the corresponding location.

The output preserves Ubuntu's source version and appends `+getpatched1`. Later patches on the same source increment the serial; changed distro source requires a separately pinned target and fresh tests.

## Regression evidence and limits

The regression fixture is GitHub Security Lab's public `bug.pdf`, copied from `SecurityExploits/freedesktop/poppler-CVE-2025-52885` at Git blob `57b7c92aa4442c21aa570ab0de190ba2f4aa0827`. It is MIT-licensed; the license and attribution are retained in `LICENSES/` and `tests/fixtures/README.md`.

On pristine Ubuntu Focal source version `0.86.1-0ubuntu1.7`'s upstream 0.86.1 code, a native AddressSanitizer source build aborts on `pdfinfo -struct bug.pdf` with `heap-use-after-free` in `StructTreeRoot::parentTreeAdd`. The same source build with this backport exits successfully without an AddressSanitizer error. Raw logs and the fixture checksum are recorded in the GetPatched platform repository under `evidence/poppler-cve-2025-52885-source-regression-20261030/`.

This is source-level evidence from macOS/AppleClang, not an Ubuntu `.deb` build or installed-package result. The candidate is not release-ready until the hosted Ubuntu build, installed baseline/patched regression, package-aware before/after scan, normal consumer checks, and fresh signed APT client tests pass.

The platform's installed-package regression runner uses Valgrind Memcheck, not AddressSanitizer: it requires the exact baseline package to report the `StructTreeRoot::parentTreeAdd` invalid access and the patched package to complete with zero Memcheck errors. The native macOS ASan logs above are separate source-level evidence.

The target lists all binary packages produced by the Ubuntu source package so ABI-coupled libraries and their consumers remain version-aligned. No package binaries are published by this recipe.

## Debian backport: CVE-2026-107705

The Debian Security Tracker currently marks Bookworm and Trixie vulnerable. Their exact `Sources` entries were read from the Debian Snapshot `20261030T000000Z` indexes, whose `InRelease` signatures were verified with the official Debian archive keyring and whose `Sources.xz` hashes matched the signed index. The target JSON files pin each descriptor and source archive by SHA-256. Ubuntu Focal is not included for this CVE because Canonical lists it as needing evaluation; this recipe does not infer applicability from the upstream affected-version range.

The upstream fix is commit [`60e19a30152560fcccfb2ae7f7559eda560c0160`](https://gitlab.freedesktop.org/poppler/poppler/-/commit/60e19a30152560fcccfb2ae7f7559eda560c0160). Its patch does not apply verbatim to the Bookworm and Trixie source revisions because it includes a later `GooString` to `std::string` refactor. The target-scoped backport instead clamps `revision6Hash()`'s existing `GooString` length to 127 bytes. This matches the limit already used by `makeFileKey()` and bounds both fixed-size buffers. It applies only to the exact source versions listed above.

The regression probe uses Poppler's exported `PDFDoc` API to open a small encrypted revision 6 PDF with a 180-byte owner password. The fixture is pinned from qpdf's public qtest corpus at commit `4eba95899886e851cc41d76886483b347612f2a8`; its source and Artistic-2.0 license are recorded under `tests/fixtures/` and `LICENSES/`. The hosted baseline run must report an invalid write from `libpoppler` under Valgrind; the patched installed-package run must complete with zero Memcheck errors. Both checks and the package-aware before/after scan are pending. Until those results exist, these Debian rows are candidates, not verified fixes or release claims.

`binaryPackages` lists every output binary required in the candidate release. `advisoryPackages` lists the binaries that contain or ship the vulnerable Poppler code and therefore belong in CVE records and package-aware scan expectations. The documentation-only `libpoppler-glib-doc` binary remains in the build and release set but is excluded from the CVE affected-package list.

## Licensing

The MIT license in `LICENSE` applies only to original GetPatched-authored recipe metadata, tests, and documentation. The security patch is a context-adjusted port of Poppler code and is identified as `GPL-2.0-only` in `package-manifest.json` and `patches/metadata.json`; it is not relicensed under MIT. The CVE-2025-52885 PoC retains its upstream MIT license; the qpdf R6 fixture retains its Artistic-2.0 license. Poppler, qpdf, and Ubuntu copyright/license notices are preserved in `LICENSES/`; preserve upstream and distribution obligations in every source and binary package.
