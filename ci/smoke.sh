#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cd "$work"
python3 - <<'PY'
from pathlib import Path

objects = [
    b"<< /Type /Catalog /Pages 2 0 R >>",
    b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
    b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 72 72] /Resources << >> >>",
]
pdf = bytearray(b"%PDF-1.4\n")
offsets = []
for number, content in enumerate(objects, 1):
    offsets.append(len(pdf))
    pdf.extend(f"{number} 0 obj\n".encode() + content + b"\nendobj\n")
xref = len(pdf)
pdf.extend(b"xref\n0 4\n0000000000 65535 f \n")
for offset in offsets:
    pdf.extend(f"{offset:010d} 00000 n \n".encode())
pdf.extend(f"trailer\n<< /Size 4 /Root 1 0 R >>\nstartxref\n{xref}\n%%EOF\n".encode())
Path("sample.pdf").write_bytes(pdf)
PY
pdfinfo sample.pdf > info
grep -Eq '^Pages:[[:space:]]+1$' info
