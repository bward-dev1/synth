#!/bin/bash
# Package an unsigned iOS app into an IPA

set -e

if [ $# -ne 2 ]; then
    echo "Usage: package-ipa.sh <app-dir> <output-ipa>"
    echo "Example: package-ipa.sh build/Build/Products/Release-iphoneos/Synth.app Synth.ipa"
    exit 1
fi

APP_DIR="$1"
OUTPUT_IPA="$2"
TEMP_DIR=$(mktemp -d)

# Create Payload directory structure
mkdir -p "$TEMP_DIR/Payload"
cp -r "$APP_DIR" "$TEMP_DIR/Payload/"

# Create symlinks for standard directories if needed
mkdir -p "$TEMP_DIR/Symbols"

# Package as ZIP (IPA is just a renamed ZIP)
cd "$TEMP_DIR"
zip -r -q "$OUTPUT_IPA" Payload Symbols
cd - > /dev/null

# Move IPA to current directory
mv "$TEMP_DIR/$OUTPUT_IPA" "$OUTPUT_IPA"

# Cleanup
rm -rf "$TEMP_DIR"

echo "✓ IPA packaged: $OUTPUT_IPA"
