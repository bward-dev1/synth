# Synth Setup & Build Instructions

## Quick Start (GitHub Actions Auto-Build)

### 1. Create GitHub Repository

```bash
cd /path/to/synth
git remote add origin https://github.com/bward-dev1/synth.git
git push -u origin main
```

### 2. Configure SendGrid (Optional - for auto email)

To automatically email the IPA after each build:

1. Create a free SendGrid account: https://sendgrid.com
2. Generate an API key in your SendGrid dashboard
3. Add it to your GitHub repo secrets:
   - Go to Settings → Secrets and variables → Actions
   - Create `SENDGRID_API_KEY` with your SendGrid API key

Without SendGrid configured, the IPA will still be available in GitHub Actions artifacts for manual download.

### 3. Trigger Build

Push to main branch (or manually trigger via Actions tab):

```bash
git push origin main
```

The GitHub Actions workflow will:
1. Check out the code
2. Generate Xcode project with XcodeGen
3. Build unsigned IPA on macOS 15
4. Package as .ipa file
5. Email to blwlego@gmail.com (if SendGrid key configured)
6. Upload as artifact (always available)

---

## Local Build (Requires Full Xcode)

If you have Xcode 15+ installed:

```bash
# Generate Xcode project
xcodegen generate

# Build for iOS device
xcodebuild build \
  -scheme Synth \
  -sdk iphoneos \
  -configuration Release \
  -derivedDataPath build \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO

# Package IPA
mkdir -p Payload
cp -r build/Build/Products/Release-iphoneos/Synth.app Payload/
mkdir -p Symbols
zip -r Synth.ipa Payload Symbols

# Synth.ipa is now ready to sideload
```

---

## Sideload Instructions

Once you have the IPA:

### Option 1: LiveContainer (Recommended)
1. Install [LiveContainer](https://livecontainer.io/) from TestFlight
2. Open LiveContainer
3. Tap the + icon and select Synth.ipa
4. Install and launch

### Option 2: StikDebug
1. Install [StikDebug](https://github.com/nythepegasus/StikDebug)
2. Open StikDebug
3. Select Synth.ipa
4. Install and launch

### Option 3: SideStore
1. Install [SideStore](https://sidestore.io/)
2. Add Synth.ipa through the interface
3. Install and launch

---

## First Launch

When you open Synth for the first time:

1. **Editor tab** shows a JavaScript code editor
2. **Run button** executes the script and generates content
3. **Preview pane** displays generated textures, meshes, or audio status
4. **Export button** allows sharing PNG/OBJ files via iOS Files/iCloud/Drive

### Example Scripts

**Generate fBm Noise Texture:**
```javascript
texture.fbmNoise(2.0, 4, 2.0)
```

**Generate Sphere Mesh:**
```javascript
mesh.sphere(1.0)
```

**Synthesize FM Sound:**
```javascript
audio.fmSynth(2.0, 10.0, 2.0)
```

---

## Device Compatibility

- **iOS 15.0 or later**
- **iPad Pro 9.7 (A9X, 2GB)** — legacy tier (512×512 textures, no ML)
- **iPad Pro 11" (A12Z+)** — mid tier (1024×1024 textures, CPU ML)
- **iPad Pro M1+ / M-series** — modern tier (2048×2048 textures, Neural Engine)

DeviceProfile automatically detects your device and adjusts limits.

---

## Troubleshooting

### Build Fails
- Ensure you have Xcode 15+ (for local builds)
- Check that xcodegen is installed: `brew install xcodegen`
- Verify project.yml is valid: `xcodegen generate`

### IPA Won't Sideload
- Ensure device is on iOS 15.0+
- Try a different sideloading tool (LiveContainer, StikDebug, SideStore)
- Check that the IPA is properly signed for sideloading

### App Crashes on Launch
- Check device tier: Script generation limits vary by device
- Try simpler scripts first (e.g., `texture.fbmNoise(1.0, 2, 2.0)`)
- Check console output for error details

---

## Next Steps

1. **Push to GitHub** and enable Actions
2. **Configure SendGrid** for auto email delivery (optional)
3. **Sideload the IPA** and start creating!
4. **Export assets** for use in Hexarch, Minecraft modding, or other projects

Enjoy building!
