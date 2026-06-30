# Synth — Creative Coding Sketchpad for iOS

An offline iOS app for generating textures, 3D meshes, and synthesized audio using live JavaScript code. Export assets for Minecraft modding, game development, and procedural art projects.

**Status:** v1 complete, ready to sideload  
**Build:** iOS 15.0+ | Works on iPad Pro 9.7 (A9X) through M-series  
**Author:** Brandon (12)

---

## What's Inside

### Texture Module
Procedural noise generation (Perlin, Simplex, fBm) with real-time preview and PNG export optimized for Minecraft resource packs.

### Mesh Module
Generate 3D geometry procedurally: spheres, L-systems, SDF-based shapes. Export as OBJ (Blockbench-compatible) or USDZ (iOS preview).

### Audio Module
FM synthesis, additive synthesis, and other synthesis engines. Generate WAV files for game audio, Minecraft sound packs, etc.

### Live Coding
Write JavaScript in the app, hit Run, see results instantly. No server, no internet — everything runs on-device.

---

## Get It Running

### Option A: Build from Source (Requires Xcode 15+)

```bash
# Clone or download this repo
cd synth

# Generate Xcode project
xcodegen generate

# Build unsigned IPA
xcodebuild build -scheme Synth -sdk iphoneos -configuration Release \
  -derivedDataPath build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO

# Package as IPA
mkdir -p Payload
cp -r build/Build/Products/Release-iphoneos/Synth.app Payload/
mkdir -p Symbols
zip -r Synth.ipa Payload Symbols
```

### Option B: Use GitHub Actions (Automatic)

1. Push this repo to GitHub
2. GitHub Actions automatically builds on every push
3. IPA is available in workflow artifacts
4. (Optional) Configure SendGrid for auto email to blwlego@gmail.com

**Minimal setup:**
```bash
git remote add origin https://github.com/yourusername/synth.git
git push -u origin main
```

GitHub Actions will build automatically. IPA appears in Actions → Artifacts within ~10 minutes.

**With email delivery (optional):**
1. Create free SendGrid account: https://sendgrid.com
2. Get API key from SendGrid dashboard
3. Add to GitHub repo: Settings → Secrets → `SENDGRID_API_KEY`
4. Next push will auto-email the IPA to blwlego@gmail.com

---

## Sideload to iPad

Once you have the IPA:

### LiveContainer (Easiest)
1. Install [LiveContainer](https://livecontainer.io/) (free, no jailbreak)
2. Open LiveContainer
3. Tap + and select Synth.ipa
4. Install and run

### StikDebug or SideStore
- [StikDebug](https://github.com/nythepegasus/StikDebug): Mac + debugger interface
- [SideStore](https://sidestore.io/): Community app store, persistent installs

---

## Use It

After launching Synth:

```javascript
// Generate fBm noise texture (256×256, grayscale)
texture.fbmNoise(scale: 2.0, octaves: 4, lacunarity: 2.0)

// Generate sphere mesh (OBJ format)
mesh.sphere(radius: 1.0)

// Synthesize FM sound (stereo, 44.1 kHz)
audio.fmSynth(ratio: 2.0, index: 10.0, duration: 2.0)
```

Hit the **Run** button. Preview appears in the preview pane. Hit **Export** to save PNG/OBJ/WAV to iCloud Drive or Files.

---

## Device Tiers

Automatically adapts to your device:

| Device | Texture | Mesh Polys | Audio | ML |
|--------|---------|-----------|-------|-------|
| **iPad Pro 9.7 (A9X)** | 512×512 | 100K | 4 voices | ❌ |
| **iPad Pro 11" (A12Z+)** | 1024×1024 | 500K | 8 voices | ⚠️ CPU only |
| **iPad Pro M1+ / Mac** | 2048×2048 | 2M | 16 voices | ✅ Neural Engine |

No manual config — DeviceProfile detects on launch.

---

## Export

- **PNG**: Texture images. Minecraft presets force power-of-2 dimensions.
- **OBJ**: 3D meshes, Blockbench/Minecraft-compatible, universally readable.
- **WAV**: Uncompressed audio, 44.1 kHz stereo, re-processable in DAWs.

All exports go via iOS Files or iCloud Drive for easy transfer to Mac/other projects.

---

## Architecture

- **7 Swift Packages**: SynthCore (DeviceProfile), SynthScripting (JSC bridge), SynthUI (editor), SynthTexture/Mesh/Audio (generation), SynthDocs (reference)
- **JavaScriptCore** for live scripting, native Metal/AVAudioEngine for heavy lifting
- **Zero external dependencies** — all generation is procedural, no pre-trained models
- **Offline-first** — no internet, no cloud, no accounts

See `docs/ARCHITECTURE.md` for technical depth.

---

## What's V1, What's V2

**V1 (Now):**
- ✅ Full procedural texture/mesh/audio generation
- ✅ Live JS editor with syntax highlighting
- ✅ PNG/OBJ/WAV export
- ✅ Device tiering (A9X → M-series)
- ✅ Watchdog timeout (no infinite loops)

**V2+ (Future):**
- ❌ Generative mesh ML (doesn't exist in deployable mobile form yet)
- Audio ML filters
- More export formats (glTF, AIFF, KTX2)
- Mac Catalyst
- Visual node-graph editor
- Persistent project browser

---

## Docs

- **ARCHITECTURE.md** — Design, modules, data flow, constraints
- **DEVICE_PROFILES.md** — Tier specs, gating logic, testing
- **EXPORT_FORMATS.md** — Asset formats, round-trip workflows
- **SETUP.md** — Step-by-step build & sideload instructions

---

## Known Gaps

- Scripts are single-threaded (no parallelism)
- No persistent project auto-save (use export)
- No cloud (offline only by design)
- No generative mesh ML (field-wide limitation, not a cut corner)

---

## Support

- **GitHub Issues**: Report bugs, request features
- **Docs**: See `docs/` folder for technical deep-dives
- **Source**: Fully open source, MIT-style license

---

## Built By

**Brandon** (age 12), solo iOS developer  
Supported by Claude Code

Synth pairs with his other projects:
- **Hexarch** — Metal-native iOS hex strategy game (PBR shaders, synth audio, procedural generation)
- **MC Launcher** — Custom Java Edition launcher with auth, LAN play, mods
- **KiddReads** — Children's book catalog (Next.js/Supabase)

---

**Ready to create?** Start with `SETUP.md` or `docs/DEVICE_PROFILES.md`.
