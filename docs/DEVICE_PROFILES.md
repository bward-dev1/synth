# Device Profiles & Tiering

Synth automatically detects your device at launch and adjusts resource limits. No manual configuration needed.

## Detection Logic

DeviceProfile reads:
- `ProcessInfo.processInfo.physicalMemory` — RAM available
- `ProcessInfo.processInfo.activeProcessorCount` — CPU cores
- `MTLDevice.supportsFamily(.apple4+)` — Neural Engine presence

## Tiers

### Legacy (A9X, 2GB RAM)
**Example device:** iPad Pro 9.7 (2015)

- No Neural Engine (introduced A11)
- Limited memory, single-core GPU
- **Texture max:** 512×512
- **Mesh max polygons:** 100,000
- **Marching cubes grid max:** 32³
- **ML models:** Disabled
- **Audio polyphony:** 4 voices
- **Live-as-you-type:** Disabled — use Run button

**Implications:** Smaller previews, longer execution times on complex scripts, no ML stylization. The app is still fully functional; just more constrained.

### Mid (A12Z, ~6GB RAM)
**Example devices:** iPad Pro 11" (2020–2021), iPad Air (2022)

- Neural Engine present, but relatively modest
- Good GPU (4-6 cores)
- **Texture max:** 1024×1024
- **Mesh max polygons:** 500,000
- **Marching cubes grid max:** 64³
- **ML models:** Disabled on CPU (Neural Engine available but not all models convert cleanly)
- **Audio polyphony:** 8 voices
- **Live-as-you-type:** Enabled with reasonable debounce (~300ms)

**Implications:** Nice balance between capability and responsiveness. Can run most scripts without timeout.

### Modern (M-series, 8GB+)
**Example devices:** iPad Pro 12.9" (2024+), iPad Air M1+, any M-series Mac via Catalyst

- Full Neural Engine (4–16 cores)
- Powerful GPU (8–10 cores)
- **Texture max:** 2048×2048
- **Mesh max polygons:** 2,000,000
- **Marching cubes grid max:** 128³
- **ML models:** Fully enabled with Neural Engine acceleration
- **Audio polyphony:** 16 voices
- **Live-as-you-type:** Enabled, fastest option (aggressive debounce possible)

**Implications:** Full feature set, no real constraints. Complex procedural generation, high-resolution exports.

## Gating in Code

Each module checks `DeviceProfile.shared.tier` or reads limits directly:

```swift
let maxTexRes = DeviceProfile.shared.maxTextureResolution  // 512, 1024, or 2048

let canUseMLA = DeviceProfile.shared.enableMLModels  // false on legacy

let liveAsYouType = DeviceProfile.shared.supportsLiveAsYouType  // false on legacy
```

No conditional code-paths for unsupported features — just adjusted thresholds. Everything works on every tier; legacy is just slower/lower-res.

## Testing Across Tiers

If you only have one device, you can simulate a lower tier by:

1. Edit `DeviceProfile.swift` to hardcode a lower tier in the initializer.
2. Build and run locally (on the simulator or device).
3. Verify that limits apply: texture previews shrink, marching cubes grids are coarser, etc.

Example (simulate legacy):

```swift
// In DeviceProfile.init()
self.tier = .legacy  // Force legacy tier
self.maxTextureResolution = 512
// ... (rest of legacy limits)
```

Revert before committing.

## ML on Different Tiers

**Legacy:** Zero ML. No Core ML inference at all. Style filters and RNN modulation disabled.

**Mid:** CPU-only Core ML inference. Neural Engine is present but we conservatively avoid it at this tier (no guarantees on all model formats). CPU inference is slower but reliable.

**Modern:** Full Neural Engine acceleration. Fastest inference, all models available.

This can be adjusted per-module if certain models prove more portable than others.
