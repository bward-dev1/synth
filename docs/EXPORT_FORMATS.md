# Export Formats

Synth exports assets in formats that integrate directly into your other projects: Hexarch, Minecraft modding, game engines, audio workstations, etc.

## Texture (PNG)

**Format:** Portable Network Graphics (32-bit RGBA with sRGB color space)

**Why PNG:**
- Universal, zero licensing issues
- Supports lossless compression and transparency
- Both Minecraft resource packs and game engines (Metal, Unity, etc.) natively read PNG
- No quality loss

**Options:**

- **Standard:** Exports at full resolution (capped by DeviceProfile max)
- **Minecraft preset:** Forces power-of-two dimensions (16, 32, 64, 128, 256, 512, 1024) for MC resource pack compatibility

**Normal Maps:** Exported as **linear-space** PNG (not sRGB). Tagged with appropriate color space metadata so Minecraft/game engines interpret them correctly.

**Example workflow:**
```
Script → texture.fbmNoise(...) → texture.domainWarp(...) → [Export PNG]
→ iCloud Drive → download on Mac → drag into Minecraft resource pack folder
```

## Mesh (OBJ + USDZ)

### OBJ (Wavefront)
**Format:** Plain-text 3D mesh format (vertices, faces, normals, UVs)

**Why OBJ:**
- Universal standard, supported everywhere
- Minecraft's Blockbench and structure modding tools natively import OBJ
- Hexarch's Metal loader can parse OBJ
- Human-readable for inspection/debugging

**Included in OBJ export:**
- Vertices (v)
- Normals (vn) — computed via face normals
- Faces with vertex/normal references (f)
- No materials/textures in the file (you can add separately)

**Example workflow:**
```
Script → mesh.sphere(...) → mesh.lsystem(...) → [Export OBJ]
→ iCloud Drive → open in Blockbench → tweak/paint → export to Minecraft
```

### USDZ (Pixar Universal Scene Description)
**Format:** Apple's native 3D scene format (iOS AR Quick Look, Preview.app)

**Why USDZ:**
- Native to iOS — Quick Look preview in Files.app
- Good for iterating visually on the device itself
- Can re-import and re-generate if you adjust the script

**Included in USDZ export:**
- Mesh geometry
- Normals
- Smooth shading groups
- No materials initially (can add in Xcode's Reality Composer if needed)

**Example workflow:**
```
Script → mesh.sdf.smoothUnion(...) → [Export USDZ]
→ Files → tap to open in Quick Look → rotate/inspect on iPad
```

## Audio (WAV)

**Format:** Waveform Audio File Format (uncompressed PCM, 44.1 kHz 16-bit stereo)

**Why WAV:**
- Uncompressed — no quality loss, exactly what was synthesized
- Industry standard for audio source material
- Re-processable: can load into Audacity, Ableton, game audio middleware, etc.
- Correct choice for asset source files (lossy formats like MP3 discard data permanently)

**Export options:**
- **Duration:** Set in script (e.g., `duration: 2.0` for 2 seconds)
- **Sample rate:** 44.1 kHz (fixed for v1; 48 kHz optional in v2)
- **Channels:** Mono or stereo (depends on synthesis module)

**Example workflow:**
```
Script → audio.fmSynth(ratio: 2.0, index: 10.0, duration: 3.0) → [Export WAV]
→ iCloud Drive → load into Minecraft sound pack / game audio tool
```

## Deferred (V2+)

- **KTX2 / Basis Universal** — compressed texture formats, smaller file size, lower bandwidth. Not needed for offline use; deferred.
- **glTF** — more sophisticated 3D format with embedded materials/lighting. OBJ is sufficient for Hexarch/MC; glTF adds complexity without immediate payoff.
- **AIFF** — alternative audio format. WAV is universal; AIFF adds no practical benefit.
- **USDZ with materials** — bundled PBR material data. Possible post-v1 enhancement.

## File Naming & Organization

Exports are saved via `ShareLink` / `UIDocumentPickerViewController`, so the user picks the location:

```
Files → iCloud Drive (or Google Drive, OneDrive, etc.)
    → mysketch_texture_20240630.png
    → mysketch_mesh_20240630.obj
    → mysketch_mesh_20240630.usdz
    → mysketch_audio_20240630.wav
```

Timestamp in filename prevents accidental overwrites during iteration.

No custom asset management UI in v1 — the OS Files app is the source of truth.

## Round-Trip Example (Hexarch → Synth → Hexarch)

1. **In Synth:** Write a script that generates a procedural terrain mesh
   ```javascript
   let plane = mesh.plane(width: 10, height: 10, segs: 64);
   let terrain = mesh.displacementNoise(plane, scale: 5.0, strength: 1.5);
   ```

2. **Export OBJ** → iCloud Drive

3. **On Mac:** Download the OBJ, load into Hexarch's mesh-import pipeline

4. **In Hexarch:** The mesh appears in your scene, texturable and game-ready

Similarly for textures (procedural terrain texture from Synth → resource pack for Minecraft).

## Validation

After exporting, always spot-check:
- **PNG:** Open in Preview.app, verify colors and no corruption
- **OBJ:** Open in Blockbench or a 3D viewer, check face orientation and normals
- **USDZ:** Quick Look in Files.app, verify geometry
- **WAV:** Play in Music.app or Audacity, listen for artifacts

If something looks wrong, it's often easier to re-run the script with adjusted parameters than to fix the asset post-export.
