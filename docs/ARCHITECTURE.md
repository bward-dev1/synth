# Synth Architecture

## Overview

Synth is an offline creative-coding sketchpad for iOS/iPadOS that generates textures, 3D meshes, and audio entirely on-device. The architecture separates concerns across seven local Swift Packages (SPM) and uses JavaScriptCore as the live-coding scripting engine.

## Core Design Principles

### 1. Scripting vs. Native Execution

**The Problem:** Swift cannot be parsed and executed from source text at runtime on non-jailbroken iOS. There's no on-device Swift compiler/JIT available to sideloaded apps.

**The Solution:** Use JavaScriptCore (JSC), which ships free with the OS. Developers write JavaScript that calls into native Swift/Metal/AVAudioEngine code via `JSExport` bridges. The script layer is **orchestration and composition**; the native layer is the **heavy lifting** (per-pixel/per-vertex/per-sample work).

### 2. ML is Auxiliary, Not Generative

Across all three modules, the honest pattern is the same:

- **Texture:** Procedural noise/warping generates the base; small Core ML style-transfer filters apply post-processing (stylization).
- **Audio:** Procedural synthesis engines generate the base; small Core ML RNN generates control curves (modulation) driving the synth.
- **Mesh:** Procedural generation (parametric, L-systems, SDF/CSG) is the real engine. **No deployable on-device generative mesh ML exists anywhere in the mobile ecosystem today** — even on M-series iPads. This is documented as a named gap, not a cut corner.

### 3. Device Tiering (DeviceProfile)

Because Brandon's devices range from an iPad Pro 9.7 (A9X, 2GB) to newer M-series hardware, every module is gated by a DeviceProfile computed at launch. This is load-bearing from day one, not a v2 optimization.

Tiers: `.legacy` (A9X/2GB, no Neural Engine) → `.mid` (A12Z, has Neural Engine) → `.modern` (M-series). Gating: texture resolution, marching-cubes grid resolution, polygon caps, ML enablement, and live-vs-debounced execution.

## Package Structure

```
Synth/
├── project.yml               # XcodeGen configuration
├── Packages/
│   ├── SynthCore/
│   │   └── DeviceProfile.swift   # Device tiering logic
│   ├── SynthScripting/           # JSC engine, JSExport bridge, watchdog
│   ├── SynthTexture/             # Metal compute kernels, Core ML styling
│   ├── SynthMesh/                # Procedural generators, marching cubes, OBJ/USDZ export
│   ├── SynthAudio/               # AVAudioEngine, synth DSP, offline render
│   ├── SynthUI/                  # Editor, preview panes, export sheet
│   └── SynthDocs/                # Bundled offline reference docs
├── App/
│   └── SynthApp.swift            # SwiftUI entry point
├── docs/
│   ├── ARCHITECTURE.md           # This file
│   ├── DEVICE_PROFILES.md        # Tier specifications
│   ├── EXPORT_FORMATS.md         # Asset format details
│   └── BRAND.md                  # UI/UX guidelines
├── .github/
│   └── workflows/
│       └── build-ipa.yml         # Unsigned IPA CI
└── scripts/
    └── package-ipa.sh            # IPA packaging helper
```

## Module Details

### SynthCore
- **DeviceProfile:** Detects device tier at launch, exposes as SwiftUI environment value, gates all resource-intensive features.
- **Shared utilities:** File I/O, project model, document format (.synthsketch package).
- No dependencies.

### SynthScripting
- **ScriptEngine:** Wraps JSContext, manages evaluation on background thread with wall-clock timeout (~2s).
- **JSExport bridges:** TextureAPI, MeshAPI, AudioAPI, ParamAPI expose native methods to JavaScript.
- **Watchdog:** Times out runaway scripts; on timeout, abandons the JSContext and spins up a fresh one for the next run. (JSC has no safe interrupt API for third-party apps — this is the practical workaround.)
- **Console capture:** Logs `console.log()` calls from scripts to a SwiftUI-bound output pane.

### SynthTexture
- **Procedural:** Perlin, Simplex, Worley, fBm, ridged-multifractal, curl noise, Gray-Scott reaction-diffusion, Voronoi, SDF patterns, normal-map derivation, seamless tiling.
- **Implemented via Metal compute kernels** — one kernel per algorithm, composable.
- **ML:** Small Core ML feedforward models (1–7MB each) for style-transfer filters; applied as **post-processing** on procedural output, not as generators.
- **Export:** PNG (with Minecraft power-of-two preset), normal maps as linear-tagged PNG. JPEG for display only.

### SynthMesh
- **Procedural:** Parametric surfaces (spheres, tori, superquadrics), noise-displaced primitives, L-systems with 3D turtle, SDF/CSG composition (union, smooth-union, subtract, intersect), Voronoi fracture, Catmull-Clark subdivision.
- **Marching cubes:** Extract mesh from SDF with grid-resolution gating per DeviceProfile tier.
- **No generative mesh ML.** That capability doesn't exist in deployable mobile form anywhere today. If Brandon wants an ML flavor here, a lightweight parameter-suggestion heuristic is offered as clearly distinct from "mesh generation."
- **Export:** OBJ (universally readable, Minecraft/Blockbench-friendly), USDZ (native iOS preview).

### SynthAudio
- **Procedural:** Subtractive synth, FM (operator-based, DX7-style), additive, granular, wavetable, Karplus-Strong, LFO modulation matrix.
- **Implemented via AVAudioEngine** + custom render callback using `AVAudioSourceNode`.
- **Realtime-audio constraint (critical):** The render callback is realtime-priority — **no Swift allocations, ARC churn, or locks allowed inside it.** This is the single most common way custom DSP breaks on iOS. Documented explicitly in code comments and here.
- **ML:** Small Core ML RNN/GRU that generates **control curves** (filter cutoff, pitch bend, mod index) driving the procedural synth. Real, fast, small (< 5MB). Offline-rendered for export.
- **Export:** WAV (uncompressed, correct choice for asset source material). Lossy formats out of scope.

### SynthUI
- **Editor:** Hand-rolled syntax-highlighted code editor (UITextView via UIViewRepresentable). No WKWebView/Monaco — keeps JS↔Metal/Audio integration simple.
- **Execution:** Debounced auto-run (~300ms after typing stops) + explicit Run button. Live-as-you-type gated to `.modern` and `.mid` tiers only, off by default for `.legacy`.
- **Parameter panel:** Auto-generated from `param("name", min, max)` calls in the script. Sliders update without full re-run.
- **Preview panes:** Metal-backed texture/mesh previews (MTKView via UIViewRepresentable), waveform/spectrum view for audio.
- **Export sheet:** Save PNG/OBJ/USDZ/WAV via ShareLink into Files/iCloud/Drive.

### SynthDocs
- **Bundled offline reference** in Markdown format. Loaded at startup, searchable in-app.
- Covers texture API, mesh API, audio API, device profiles, export formats, algorithm explanations.

## Data Flow

```
User types script
    ↓
EditorView debounces / Run button pressed
    ↓
ScriptEngine.execute(script, timeout: 2s)
    ↓ (background thread)
JSContext.evaluateScript(script)
    ↓
Script calls texture.fbmNoise(...), mesh.sphere(...), audio.fmSynth(...)
    ↓ (JSExport → native bridging)
TextureAPI.fbmNoise() → dispatch Metal compute kernel
MeshAPI.sphere() → build vertex buffer
AudioAPI.fmSynth() → offline-render to AVAudioFile
    ↓
Result published via @Observable/Combine
    ↓
Preview pane updates (MTKView renders texture, etc.)
    ↓
Export: `ShareLink` writes PNG/OBJ/USDZ/WAV to user's Files/iCloud/Drive
```

## Document Model

Projects are stored as `.synthsketch` packages:

```
mysketch.synthsketch/
├── script.js              # The JavaScript source
├── meta.json              # {module: "texture", lastParams: {...}}
└── thumbnail.png          # Cached preview for project browser
```

Not a generic `DocumentGroup` — Synth has a custom in-app project browser for browsing, opening, and managing sketches. This allows the app to show thumbnails and metadata without needing to re-execute scripts on every browser refresh.

## Build & CI

- **XcodeGen:** `project.yml` declares all packages, frameworks, app target, and build settings (unsigned IPA, `CODE_SIGNING_ALLOWED=NO`).
- **GitHub Actions:** Builds on `macos-15`, runs `xcodebuild` with no code signing, packages unsigned IPA via `scripts/package-ipa.sh` (a simple `zip` wrapper).
- **Artifact delivery:** Uploads IPA to Google Drive (via rclone or service-account API, credentials in repo secrets).
- **Sideloading:** Brandon uses LiveContainer/StikDebug/SideStore to install the IPA on real devices.

## Verification Checklist

1. ✓ CI produces unsigned IPA from clean `xcodebuild` run — confirms pipeline matches his existing repos.
2. ✓ Sideload on real device, confirm app launch and DeviceProfile identifies tier correctly.
3. ✓ Smoke test: write short script using texture.*, mesh.*, audio.* primitives, confirm live preview updates.
4. ✓ Watchdog: intentional `while(true)` script is aborted at 2s timeout.
5. ✓ Export round-trip: generate asset, export to PNG/OBJ/WAV, confirm it opens in external tools.
6. ✓ Legacy-tier check: A9X profile correctly gates resolution/polygon/ML limits.

## Future (V2+)

- Generative mesh ML: deferred pending field-wide advancement (doesn't exist today).
- Audio timbre-transfer ML: real sourcing/training/conversion lift; lower priority than v1 features.
- Format breadth: KTX2, glTF, AIFF — widening export options, not core capability.
- Mac Catalyst: platform breadth.
- Visual node-graph companion: optional alternative to text-code iteration.
- Live-as-you-type on legacy hardware: possible future optimization, currently default-off for safety.
