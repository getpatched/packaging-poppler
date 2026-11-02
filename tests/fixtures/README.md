# Regression fixture provenance

`bug.pdf` is the public CVE-2025-52885 reproducer from [GitHub Security Lab](https://github.com/github/securitylab/tree/main/SecurityExploits/freedesktop/poppler-CVE-2025-52885), fetched from Git blob `57b7c92aa4442c21aa570ab0de190ba2f4aa0827`.

- SHA-256: `670d369c3cfff9cb417b40260695a715c2d2e3236fafd04464965842559ae545`
- License: MIT; see [`../../LICENSES/SECURITYLAB-MIT-LICENSE`](../../LICENSES/SECURITYLAB-MIT-LICENSE).
- Expected vulnerable behavior: `pdfinfo -struct bug.pdf` triggers a heap-use-after-free in the Poppler structure-tree path.
- Expected fixed behavior: the same command completes without a memory-safety report.

The binary is retained unchanged. Do not use it outside a disposable test process against the explicitly selected Poppler source/package builds.

`CVE-2026-107705-r6-encrypted.pdf` is qpdf's public R6 input fixture, copied from qpdf commit `4eba95899886e851cc41d76886483b347612f2a8`, file `qpdf/qtest/qpdf/c-r6-in.pdf`. Its PDF encryption dictionary contains `/R 6` and `/V 5`.

- SHA-256: `b616425b595e376dbbfc19dbb89a66678afd4eb74f85575f667778afa1add892`
- License: Artistic-2.0; see [`../../LICENSES/QPDF-ARTISTIC-2.0`](../../LICENSES/QPDF-ARTISTIC-2.0). qpdf's [`LICENSE.txt`](../../LICENSES/QPDF-APACHE-2.0) identifies its qtest corpus as Artistic-2.0.

`CVE-2026-107705-revision6-password.cpp` is a GetPatched-authored probe for Poppler's exported `PDFDoc` API. It opens that fixture with a 180-byte owner password. Valgrind must observe the baseline write beyond the fixed hash buffers and no invalid access with the patched package. It is compiled and run only inside the isolated verification container.

- SHA-256: `4bde9dc2092839564a037a169654d82327aa7d68b6503ec6733933f237735982`
- License: MIT, under this repository's public-contribution license.
