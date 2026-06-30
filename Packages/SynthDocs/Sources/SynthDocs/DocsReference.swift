import Foundation

// Bundled offline documentation for Synth API and algorithms

struct DocsReference {
    static let textureAPI = """
    # Texture Module

    ## Procedural Noise Functions

    ### fbmNoise(scale, octaves, lacunarity)
    Fractional Brownian Motion (fBm) noise — layer multiple octaves of Perlin noise.

    - `scale`: Initial frequency scale (0.1 to 100)
    - `octaves`: Number of noise layers (1 to 8)
    - `lacunarity`: Frequency multiplier per octave (1.5 to 4.0)

    Example:
    ```javascript
    let tex = texture.fbmNoise(scale: 2.0, octaves: 4, lacunarity: 2.0);
    ```

    ### simplexNoise(scale)
    OpenSimplex2 noise — smoother, faster than Perlin.

    ### worleyNoise(scale)
    Cellular/Voronoi noise — creates cell-like patterns.

    ### ridgedMultifractal(scale, octaves, lacunarity)
    Like fBm but with ridges — useful for mountains, cracks.

    ## Domain Warping

    ### domainWarp(input, strength)
    Warp the sampling coordinates of a texture using sine/cosine distortion.

    - `strength`: Warp intensity (0.0 to 10.0)

    Example:
    ```javascript
    let base = texture.fbmNoise(scale: 2.0, octaves: 4, lacunarity: 2.0);
    let warped = texture.domainWarp(input: base, strength: 3.0);
    ```

    ## ML Stylization

    ### applyStyle(input, styleName)
    Apply a Core ML style-transfer filter. Available styles depend on device tier.

    Bundled styles: "pastel", "oil_painting", "sketch"

    Example:
    ```javascript
    let styled = texture.applyStyle(input: tex, styleName: "pastel");
    ```

    ## Reaction-Diffusion

    ### grayScott(scale, feedRate, killRate, iterations)
    Gray-Scott reaction-diffusion simulation — creates organic, flowing patterns.

    """

    static let meshAPI = """
    # Mesh Module

    ## Parametric Primitives

    ### sphere(radius, detail)
    Generate a UV sphere.

    - `radius`: Sphere radius in units
    - `detail`: Subdivision level (6 to 256)

    ### box(width, height, depth)
    Generate a cube or rectangular box.

    ### torus(majorRadius, minorRadius, detail)
    Generate a torus (donut shape).

    ### plane(width, height, segmentsX, segmentsY)
    Generate a plane, useful as a base for displacement.

    ## Noise Displacement

    ### displacementNoise(primitive, scale, strength, octaves)
    Apply fBm-based vertex displacement along surface normals.

    Example:
    ```javascript
    let sphere = mesh.sphere(radius: 1.0);
    let rocky = mesh.displacementNoise(sphere, scale: 2.0, strength: 0.3, octaves: 4);
    ```

    ## L-Systems (Procedural Growth)

    ### lsystem(axiom, rules, generations, segmentLength)
    Generate tree-like or plant-like structures using L-system rules.

    Rules map symbols (F, X, Y) to growth patterns.

    Example (simple tree):
    ```javascript
    // F = move forward, [ = push, ] = pop (save position)
    let tree = mesh.lsystem(
        axiom: "F",
        rules: {"F": "FF[+F][-F]"},
        generations: 4,
        segmentLength: 1.0
    );
    ```

    ## SDF (Signed Distance Field) Operations

    ### sdf.sphere(position, radius)
    Define an SDF sphere at a position.

    ### sdf.box(position, size)
    Define an SDF box.

    ### sdf.union(a, b)
    Combine two SDFs via union (max).

    ### sdf.smoothUnion(a, b, k)
    Smooth union with blending factor `k`.

    ### sdf.subtract(a, b)
    Carve shape B out of shape A.

    ## Mesh Export

    ### toOBJ()
    Export generated mesh to OBJ format.

    """

    static let audioAPI = """
    # Audio Module

    ## Synthesis Techniques

    ### fmSynth(ratio, index, duration)
    Frequency Modulation synthesis (Yamaha DX7 style).

    - `ratio`: Modulator/carrier frequency ratio (0.5 to 4.0)
    - `index`: Modulation index (0.0 to 20.0)
    - `duration`: Output duration in seconds

    ### additiveSynthesis(harmonics, duration)
    Sum multiple harmonic sine waves.

    Example:
    ```javascript
    let saw = audio.additiveSynthesis(
        harmonics: [1.0, 0.5, 0.333, 0.25, 0.2],
        duration: 2.0
    );
    ```

    ### granularSynthesis(grainDuration, density, duration)
    Granular synthesis — layer short grains of sound.

    - `grainDuration`: Individual grain length (5ms to 100ms)
    - `density`: Grains per second (10 to 500)

    ### wavetableSynthesis(pitch, duration)
    Use a precomputed wavetable for efficient synthesis.

    ### karplusStrong(pitch, decay, duration)
    Plucked-string physical modeling.

    ## LFO Modulation

    ### lfo(waveform, rate, amplitude)
    Low-frequency oscillator for modulating parameters.

    Waveforms: "sine", "triangle", "sawtooth", "square"

    ## Export

    ### toWAV()
    Export synthesized audio as WAV file.

    """

    static let deviceProfiles = """
    # Device Profiles

    Synth automatically detects your device tier and adjusts limits:

    ## Legacy (A9X, 2GB RAM)
    - Max texture: 512×512
    - Max mesh polygons: 100,000
    - No ML models enabled
    - Audio polyphony: 4 voices
    - Live-as-you-type: disabled (use Run button)

    ## Mid (A12Z, ~6GB RAM)
    - Max texture: 1024×1024
    - Max mesh polygons: 500,000
    - Basic ML available (CPU-only)
    - Audio polyphony: 8 voices
    - Live-as-you-type: enabled

    ## Modern (M-series, 8GB+)
    - Max texture: 2048×2048
    - Max mesh polygons: 2,000,000
    - Full ML with Neural Engine
    - Audio polyphony: 16 voices
    - Live-as-you-type: enabled

    """
}
