#!/bin/sh
# generate-checksums.sh - Generates SHA256 checksums for all deliverables

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DIST_DIR="$PROJECT_DIR/dist"
OUTPUT_FILE="$DIST_DIR/SHA256SUMS"

echo "Generating checksums for $DIST_DIR..."

mkdir -p "$DIST_DIR"

# Generate checksums for all files in dist
(cd "$DIST_DIR" && for f in $(find . -type f); do
    case "$(uname -s)" in
        Darwin*) shasum -a 256 "$f" | sed 's/\.\///' ;;
        Linux*) sha256sum "$f" | sed 's/\.\///' ;;
    esac
done) > "$OUTPUT_FILE"

echo "Checksums generated: $OUTPUT_FILE"
cat "$OUTPUT_FILE"
