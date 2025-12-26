#!/bin/bash

# KirayaBook Release Build Script
# ================================
# This script builds the APK with secure encryption keys.
# 
# Usage:
#   ./build_release.sh
#
# For CI/CD, set these environment variables:
#   KIRAYABOOK_ENCRYPTION_KEY (32 characters)
#   KIRAYABOOK_ENCRYPTION_IV (16 characters)

set -e

# Default keys for testing (CHANGE THESE FOR PRODUCTION!)
# In production, set via environment variables or CI/CD secrets
ENCRYPTION_KEY="${KIRAYABOOK_ENCRYPTION_KEY:-KirayaBookProdKey32Characters!}"
ENCRYPTION_IV="${KIRAYABOOK_ENCRYPTION_IV:-KirayaProdIV16Ch}"

echo "🔐 Building KirayaBook with secure encryption..."
echo "   Key length: ${#ENCRYPTION_KEY} chars (should be 32)"
echo "   IV length: ${#ENCRYPTION_IV} chars (should be 16)"

# Validate key lengths
if [ ${#ENCRYPTION_KEY} -ne 32 ]; then
    echo "❌ Error: ENCRYPTION_KEY must be exactly 32 characters"
    exit 1
fi

if [ ${#ENCRYPTION_IV} -ne 16 ]; then
    echo "❌ Error: ENCRYPTION_IV must be exactly 16 characters"
    exit 1
fi

# Build release APK
flutter build apk --release \
    --dart-define=ENCRYPTION_KEY="$ENCRYPTION_KEY" \
    --dart-define=ENCRYPTION_IV="$ENCRYPTION_IV"

echo ""
echo "✅ Build complete!"
echo "   APK: build/app/outputs/flutter-apk/app-release.apk"
