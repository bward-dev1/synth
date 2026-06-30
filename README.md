# Synth

An offline creative-coding sketchpad for iOS/iPadOS. Generate textures, 3D meshes, and synthesized audio entirely on-device using live JavaScript code. Export assets for use in game modding, procedural art projects, and audio production.

## Features

### Texture Module
- Procedural noise (Perlin, Simplex, Worley, fBm, ridged-multifractal)
- Domain warping, curl noise, reaction-diffusion
- Core ML style-transfer filters (on modern devices)
- Export as PNG (with Minecraft resource pack presets)

### Mesh Module
- Parametric surfaces (spheres, tori, superquadrics)
- Noise-displaced primitives
- L-systems for procedural plant-like structures
- SDF/CSG composition with marching cubes
- Export as OBJ (Minecraft/Blockbench-compatible) or USDZ

### Audio Module
- FM synthesis, additive synthesis, granular synthesis
- Wavetable synthesis, Karplus-Strong physical modeling
- LFO modulation and subtractive synthesis engine
- Core ML control-curve generation (on modern devices)
- Export as WAV (uncompressed PCM)

### Live Coding
- JavaScript editor with syntax highlighting
- Debounced auto-run or manual Run button
- Auto-generated parameter sliders from script
- Watchdog timeout (2 seconds) for runaway scripts
- Real-time console output

## Device Support

Automatically tiers features based on device capabilities:

- **Legacy** (A9X, 2GB RAM): 512×512 textures, 100K polygons, no ML, 4-voice audio
- **Mid** (A12Z, 6GB RAM): 1024×1024 textures, 500K polygons, CPU ML, 8-voice audio
- **Modern** (M-series, 8GB+): 2048×2048 textures, 2M polygons, Neural Engine ML, 16-voice audio

## Building

### Prerequisites
- Xcode 15.0+
- xcodegen: `brew install xcodegen`

### Local Build (Simulator)
```bash
xcodegen generate
xcodebuild build -scheme Synth -sdk iphonesimulator
```

### Unsigned IPA Build (for sideloading)
```bash
# Generate project
xcodegen generate

# Build
xcodebuild build \
  -scheme Synth \
  -sdk iphoneos \
  -configuration Release \
  -derivedDataPath build \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO

# Package
./scripts/package-ipa.sh build/Build/Products/Release-iphoneos/Synth.app Synth.ipa
```

The unsigned IPA can be installed via [LiveContainer](https://livecontainer.io/), [StikDebug](https://github.com/nythepegasus/StikDebug), [SideStore](https://sidestore.io/), or similar sideloading tools.

## GitHub Actions CI

Pushes to `main` automatically build an unsigned IPA via `.github/workflows/build-ipa.yml`. The IPA is available in the workflow artifacts.

## Documentation

See `docs/` for detailed guides:
- **ARCHITECTURE.md** — Design, package structure, data flow
- **DEVICE_PROFILES.md** — Tier specifications and gating logic
- **EXPORT_FORMATS.md** — PNG, OBJ, USDZ, WAV details
- **BRAND.md** — UI/UX guidelines

Bundled offline docs are also available in-app under the Docs tab.

## Example Scripts

### Simple Texture
```javascript
let tex = texture.fbmNoise(scale: 2.0, octaves: 4, lacunarity: 2.0);
let warped = texture.domainWarp(input: tex, strength: 2.0);
```

### Simple Mesh
```javascript
let sphere = mesh.sphere(radius: 1.0);
let rocky = mesh.displacementNoise(sphere, scale: 2.0, strength: 0.3, octaves: 4);
```

### Simple Audio
```javascript
let synth = audio.fmSynth(ratio: 2.0, index: 10.0, duration: 2.0);
```

## Architecture

Synth uses JavaScriptCore as the scripting engine, bridging to native Swift/Metal/AVAudioEngine code for heavy lifting. Each feature is a local Swift Package (SPM) for clean separation of concerns. No external dependencies — everything ships offline.

See ARCHITECTURE.md for full details.

## Known Limitations (V1)

- **No generative mesh ML** — on-device generative mesh synthesis doesn't exist in deployable mobile form anywhere today. This is documented as a field-wide gap, not a cut corner.
- **Single-thread execution** — scripts run on a dedicated background thread, not in parallel.
- **No persistent projects** — sketches are not auto-saved; use export + Files.app for archival.
- **No cloud sync** — fully offline-first design.

These may be addressed in future versions as the mobile ML/Xcode ecosystem evolves.

## Future (V2+)

- Generative mesh ML (pending field advancement)
- Audio timbre-transfer ML filters
- Additional export formats (glTF, KTX2, AIFF)
- Mac Catalyst support
- Visual node-graph companion editor
- Persistent project management

## License

TBD

## Author

Built by Brandon (12 years old) with assistance from Claude Code.
