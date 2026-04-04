ClawICU test fixtures directory

This directory contains test fixtures for the ClawICU shell test suite.

Structure:
  broken-config.json5  - Invalid JSON5 for negative config tests
  valid-config.json5   - Valid minimal config for positive tests
  mock-openclaw/       - Mock openclaw binaries
    doctor-success/    - openclaw doctor exits 0
    doctor-fail/       - openclaw doctor exits 1
    version-old/       - openclaw --version returns old version
  mock-home/           - Mock home directory structure
    .openclaw/         - Mock OpenClaw state directory
