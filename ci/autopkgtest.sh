#!/usr/bin/env bash
set -euo pipefail
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
descriptors=(/originals/*.dsc)
test "${#descriptors[@]}" -eq 1
dpkg-source -x "${descriptors[0]}" "$work/source"

# Older distro scripts use ADTTMP; current Debian uses AUTOPKGTEST_TMP.
mkdir "$work/test"
ADTTMP="$work/test" AUTOPKGTEST_TMP="$work/test" sh "$work/source/debian/tests/cpp"
printf 'cpp PASS\n' > /reports/autopkgtest-summary.txt
