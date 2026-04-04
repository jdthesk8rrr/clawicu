#!/bin/sh
# verify.sh - SHA256 generation and verification

# Generate SHA256 for a file
sha256_generate() {
    local file="$1"

    if [ ! -f "$file" ]; then
        return 1
    fi

    case "$(uname -s)" in
        Darwin*)
            shasum -a 256 "$file" | awk '{print $1}'
            ;;
        Linux*)
            sha256sum "$file" | awk '{print $1}'
            ;;
        *)
            # Fallback using OpenSSL
            openssl dgst -sha256 "$file" | sed 's/^.* //'
            ;;
    esac
}

# Verify file against expected hash
sha256_verify() {
    local file="$1"
    local expected_hash="$2"

    local actual_hash="$(sha256_generate "$file")"

    if [ "$actual_hash" = "$expected_hash" ]; then
        return 0
    else
        echo "SHA256 mismatch!" >&2
        echo "Expected: $expected_hash" >&2
        echo "Actual:   $actual_hash" >&2
        return 1
    fi
}

# Generate checksums file for a directory
sha256_generate_checksums() {
    local dir="$1"
    local output="${2:-SHA256SUMS}"

    (cd "$dir" && find . -type f | while read -r f; do
        echo "$(sha256_generate "$f")  $f"
    done) > "$output"
}

# Verify all files in checksums file
sha256_verify_checksums() {
    local checksums_file="$1"
    local dir="$(dirname "$checksums_file")"

    (cd "$dir" && sha256sum -c "$checksums_file")
}
