# Regression fixture provenance

`bug.pdf` is the public CVE-2025-52885 reproducer from [GitHub Security Lab](https://github.com/github/securitylab/tree/main/SecurityExploits/freedesktop/poppler-CVE-2025-52885), fetched from Git blob `57b7c92aa4442c21aa570ab0de190ba2f4aa0827`.

- SHA-256: `670d369c3cfff9cb417b40260695a715c2d2e3236fafd04464965842559ae545`
- License: MIT; see [`../../LICENSES/SECURITYLAB-MIT-LICENSE`](../../LICENSES/SECURITYLAB-MIT-LICENSE).
- Expected vulnerable behavior: `pdfinfo -struct bug.pdf` triggers a heap-use-after-free in the Poppler structure-tree path.
- Expected fixed behavior: the same command completes without a memory-safety report.

The binary is retained unchanged. Do not use it outside a disposable test process against the explicitly selected Poppler source/package builds.
