# Building and Delivering Synth.ipa

The Synth source code is complete and ready to build. This document explains how to get the IPA built and emailed to blwlego@gmail.com.

## Why You Need This

Building iOS apps requires **Xcode**, which is large (~14GB) and requires a Mac with 4+ cores. The source code alone isn't runnable — it needs to be compiled into an `.ipa` file (iOS Package Archive).

There are two ways to build:

### Option 1: GitHub Actions (Recommended - Fully Automated)

**What happens:**
1. You push code to GitHub
2. GitHub's macOS runner (with Xcode pre-installed) builds automatically
3. The IPA is generated
4. (Optional) An email is sent to blwlego@gmail.com

**Requirements:**
- A GitHub account (free)
- (Optional) SendGrid account + API key for email delivery

**Steps:**

#### 1A. Create a GitHub Repository

```bash
# Option A: Create new repo on github.com/yourusername/synth, then:
git remote add origin https://github.com/yourusername/synth.git
git branch -M main
git push -u origin main

# Option B: Fork this repo and push to your fork
```

#### 1B. (Optional) Enable Auto-Email

To have the IPA automatically emailed to blwlego@gmail.com after each build:

1. **Create SendGrid Account**
   - Go to https://sendgrid.com
   - Sign up (free tier available, no CC required)
   - Verify sender email

2. **Get API Key**
   - Dashboard → Settings → API Keys
   - Create "Full Access" key
   - Copy the key

3. **Add to GitHub Secrets**
   - Go to your GitHub repo
   - Settings → Secrets and variables → Actions
   - New repository secret
   - Name: `SENDGRID_API_KEY`
   - Value: (paste SendGrid API key)
   - Save

#### 1C. Trigger the Build

```bash
# The build happens automatically when you push
git push origin main

# Or manually trigger:
# Go to your repo on GitHub → Actions tab → "Build & Email Synth IPA"
# Click "Run workflow" → "Run workflow" button
```

**Wait ~10 minutes.** The GitHub Actions runner will:
1. Check out the code
2. Install XcodeGen
3. Generate the Xcode project
4. Build with `xcodebuild`
5. Package the IPA
6. Email it (if SendGrid configured)
7. Upload to Artifacts (always)

**Download the IPA:**
- Go to Actions → Latest workflow run
- Scroll to Artifacts
- Download `Synth-unsigned.ipa`

If SendGrid is configured, you'll also get an email with the IPA attached.

---

### Option 2: Local Build (If You Have Xcode)

**Requirements:**
- macOS with Xcode 15+ installed
- ~30 minutes and ~20GB free disk space

**Steps:**

```bash
# Install build dependencies
brew install xcodegen

# Generate Xcode project
xcodegen generate

# Build for iOS device
xcodebuild build \
  -scheme Synth \
  -sdk iphoneos \
  -configuration Release \
  -derivedDataPath build \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  ENABLE_BITCODE=NO

# Package as IPA
mkdir -p Payload
cp -r build/Build/Products/Release-iphoneos/Synth.app Payload/
mkdir -p Symbols
zip -r Synth.ipa Payload Symbols

# Result: Synth.ipa in current directory
```

---

## Once You Have the IPA

### Sideload to iPad

Choose one method:

#### LiveContainer (Easiest)
```
1. Install LiveContainer from TestFlight (beta.livecontainer.io)
2. Open LiveContainer
3. Tap the + button
4. Select Synth.ipa from Files/Downloads
5. Install
6. Launch
```

#### StikDebug
```
1. Download StikDebug on your Mac
2. Run StikDebug
3. Connect iPad via USB
4. Select Synth.ipa
5. Install
```

#### SideStore
```
1. Install SideStore on iPad (free, community app store)
2. Add Synth.ipa through SideStore interface
3. Install and refresh as needed
```

---

## Troubleshooting

### GitHub Build Fails

**Check the build log:**
1. Go to GitHub repo → Actions tab
2. Click the failed workflow
3. Expand "Build for iOS (Release)"
4. Look for error messages

**Common issues:**
- Xcode version mismatch (CI uses macos-15, adjust if needed)
- Syntax errors in Swift code (will be listed in build log)
- Missing entitlements (unlikely for unsigned build)

**If stuck:** Share the build log URL with someone who knows Swift/Xcode.

### Sideload Fails

- Ensure device is on iOS 15.0 or later
- Try different sideload method (LiveContainer, StikDebug, SideStore)
- Check device is not in low-power mode
- Restart the app after sideload

### App Crashes on Launch

- Check device tier was detected correctly (console logs)
- Try a simpler script first: `texture.fbmNoise(1.0, 2, 2.0)`
- Ensure enough free memory (close other apps)

---

## File Locations

After building:

```
# GitHub Artifacts
github.com/username/synth → Actions → [latest run] → Artifacts

# Local build
./Synth.ipa                         # Ready to sideload
./build/Build/Products/Release-iphoneos/Synth.app  # App bundle

# Email
blwlego@gmail.com                   # Automated delivery (if SendGrid configured)
```

---

## Next: Development

Once sideloading works:

1. Edit source code in `Packages/Synth*/Sources/`
2. Commit and push to GitHub
3. CI rebuilds automatically
4. Sideload the new IPA
5. Iterate

---

## Support

- **GitHub Workflow errors**: Check `.github/workflows/build-ipa.yml`
- **Swift compilation errors**: Check `Packages/*/Sources/`
- **iOS runtime errors**: Check on-device console logs
- **Sideload issues**: Consult LiveContainer/StikDebug/SideStore docs

---

**TL;DR:**
1. Push to GitHub
2. GitHub Actions builds automatically
3. Download IPA from Artifacts (or email if SendGrid configured)
4. Sideload to iPad using LiveContainer
5. Create!

Enjoy building Synth! 🎨
