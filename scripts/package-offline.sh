#!/bin/sh
# package-offline.sh - Creates clawicu-rescue-v*.tar.gz offline package

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DIST_DIR="$PROJECT_DIR/dist"
OUTPUT_DIR="$PROJECT_DIR/packages"

VERSION="0.1.0"
PKG_NAME="clawicu-rescue-$VERSION"
PKG_DIR="$DIST_DIR/$PKG_NAME"

echo "Packaging ClawICU offline rescue package..."

# Create package directory
rm -rf "$PKG_DIR"
mkdir -p "$PKG_DIR"

# Copy bundled rescue script
mkdir -p "$PKG_DIR/rescue"
cp "$DIST_DIR/rescue.sh" "$PKG_DIR/rescue.sh"
cp -r "$PROJECT_DIR/rescue/lib" "$PKG_DIR/rescue/" 2>/dev/null || true
cp -r "$PROJECT_DIR/rescue/checks" "$PKG_DIR/rescue/" 2>/dev/null || true
cp -r "$PROJECT_DIR/rescue/repairs" "$PKG_DIR/rescue/" 2>/dev/null || true

# Create VERSION file
echo "$VERSION" > "$PKG_DIR/VERSION"

# Create SHA256SUMS
(cd "$PKG_DIR" && sha256sum * > SHA256SUMS 2>/dev/null || echo "No files to checksum" > SHA256SUMS)

# Create tar.gz
mkdir -p "$OUTPUT_DIR"
rm -f "$OUTPUT_DIR/$PKG_NAME.tar.gz"
tar -czf "$OUTPUT_DIR/$PKG_NAME.tar.gz" -C "$DIST_DIR" "$PKG_NAME"

# Also create checksums for the tarball
cd "$OUTPUT_DIR"
sha256sum "$PKG_NAME.tar.gz" > "$PKG_NAME.tar.gz.sha256"

echo "Package created: $OUTPUT_DIR/$PKG_NAME.tar.gz"
echo "Size: $(du -h "$PKG_NAME.tar.gz" | cut -f1)"
