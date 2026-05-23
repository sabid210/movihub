#!/bin/bash
# ============================================================
# MoviHub — GitHub Push + APK Build Script
# Run this from inside the project root directory
# ============================================================

set -e  # exit on any error

echo ""
echo "🎬 MoviHub — Deploy Script"
echo "======================================"
echo ""

# ── Step 1: Verify project root ──────────────────────────────
echo "📄 Step 1: Verifying project directory..."

if [ ! -f "pubspec.yaml" ]; then
  echo "❌ Error: Run this script from the movihub project root!"
  exit 1
fi

echo "✅ Project root confirmed."
echo ""

# ── Step 2: Copy docs into repo ──────────────────────────────
echo "📄 Step 2: Checking documentation files..."

if [ ! -f "README.md" ]; then
  echo "⚠️  README.md not found — make sure it's in the project root."
  exit 1
fi

if [ ! -f "DOCUMENTATION.md" ]; then
  echo "⚠️  DOCUMENTATION.md not found — make sure it's in the project root."
  exit 1
fi

echo "  ✅ README.md found"
echo "  ✅ DOCUMENTATION.md found"
echo ""

# ── Step 3: Build Release APK ────────────────────────────────
echo "📦 Step 3: Building Release APK..."
echo "  This may take 2-5 minutes on first run."
echo ""

flutter clean
flutter pub get
flutter build apk --release

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

if [ -f "$APK_PATH" ]; then
  # Get current version from pubspec.yaml
  VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
  
  # Copy APK to project root with versioned name
  cp "$APK_PATH" "./movihub-v${VERSION%%+*}.apk"
  SIZE=$(du -h "./movihub-v${VERSION%%+*}.apk" | cut -f1)
  
  echo "✅ APK built successfully!"
  echo "   Version : $VERSION"
  echo "   Size    : $SIZE"
  echo "   Location: $(pwd)/movihub-v${VERSION%%+*}.apk"
  
  APK_FILENAME="movihub-v${VERSION%%+*}.apk"
else
  echo "❌ APK build failed. Check flutter build output above."
  exit 1
fi

echo ""

# ── Step 4: Git add, commit, push ────────────────────────────
echo "🚀 Step 4: Pushing to GitHub..."

git add README.md DOCUMENTATION.md "$APK_FILENAME"

echo ""
git status
echo ""

COMMIT_MSG="docs: add README, documentation, and release APK v${VERSION%%+*}

- Added comprehensive README.md with project overview, setup guide,
  Firestore schema, and dependency list
- Added DOCUMENTATION.md with full technical docs including:
  - Screen-by-screen breakdown
  - Firestore API documentation
  - Authentication flow
  - Notification system architecture
  - Build and deployment guide
- Added $APK_FILENAME (release build)"

echo "Committing with message:"
echo "  '$COMMIT_MSG'"
echo ""

git commit -m "$COMMIT_MSG"
git push origin main

echo ""
echo "✅ All done! Check your repository:"
echo "   https://github.com/sabid210/movihub"
echo ""
echo "🎬 Summary:"
echo "   ✅ README.md        — pushed"
echo "   ✅ DOCUMENTATION.md — pushed"
echo "   ✅ $APK_FILENAME     — pushed"
echo ""
