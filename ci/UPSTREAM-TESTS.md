# Poppler upstream tests

Each target pins the official Poppler test repository at commit
`0ef006dca68d2206387eca1d36ae06733812e387`, including its archive size and
SHA-256. Shared tooling verifies the download before mounting it read-only
in the offline build container. Extraction happens inside that container.

After the native package build, CI reconfigures its existing patched CMake
tree with the corpus path and enables the GTK, Qt5 and C++ test programs.
The existing Qt6 configuration is retained where supported. The extra GTK
development dependency is installed in the isolated build environment.

CI builds the enabled programs and runs all registered CTest tests with Qt
offscreen rendering. Discovery must find Qt5 tests on every target, plus
GLib and Qt6 tests on Debian. Focal upstream registers Qt5 tests only.
Nonzero Qt skipped counts and CTest tests not run are rejected. Any build
error, test error or timeout fails the suite. CTest's discovered and executed counts remain in
the job log. The shared JUnit entry represents this suite command, not an
individual upstream assertion. Interactive manual programs are built where
enabled but are not claimed as executed tests. Package outputs were built
before this test-only reconfiguration.

This configuration still requires hosted validation on every declared target.
