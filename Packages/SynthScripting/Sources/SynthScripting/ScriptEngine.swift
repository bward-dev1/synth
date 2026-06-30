import Foundation
import JavaScriptCore
import SynthCore

class ScriptEngine {
    private let context: JSContext
    private let queue = DispatchQueue(label: "com.synth.scripting", qos: .userInitiated)
    private let timeout: TimeInterval = 2.0

    var consoleOutput: [String] = []
    var lastTextureData: [UInt8]? = nil
    var lastMeshData: String? = nil
    var lastAudioData: [Float]? = nil

    init() {
        self.context = JSContext()

        // Console capture
        consoleOutput = []
        self.context.exceptionHandler = { context, exception in
            if let exc = exception {
                print("JS Error: \(exc.description ?? "Unknown")")
            }
        }

        // texture API
        let textureAPI = ["fbmNoise": { scale, octaves, lacunarity in
            return generateFBMNoise(scale: scale as! Double, octaves: octaves as! Int, lacunarity: lacunarity as! Double)
        }] as [String: Any]
        context.setObject(textureAPI, forKeyedSubscript: "texture" as NSString)

        // mesh API
        let meshAPI = ["sphere": { radius in
            return generateSphere(radius: radius as! Double)
        }] as [String: Any]
        context.setObject(meshAPI, forKeyedSubscript: "mesh" as NSString)

        // audio API
        let audioAPI = ["fmSynth": { ratio, index, duration in
            return generateFMSynth(ratio: ratio as! Double, index: index as! Double, duration: duration as! Double)
        }] as [String: Any]
        context.setObject(audioAPI, forKeyedSubscript: "audio" as NSString)

        // Simple console.log
        context.evaluateScript("""
        var console = {
            log: function(msg) { return msg; }
        };
        """)
    }

    func execute(_ script: String, timeout: TimeInterval = 2.0) -> Result<String, Error> {
        var result: Result<String, Error>?
        let semaphore = DispatchSemaphore(value: 0)

        queue.async {
            let jsResult = self.context.evaluateScript(script)

            if let error = self.context.exception {
                result = .failure(NSError(
                    domain: "JSError",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: error.description ?? "Unknown error"]
                ))
            } else {
                let output = jsResult?.description ?? "Executed"
                result = .success(output)
            }

            semaphore.signal()
        }

        let waitResult = semaphore.wait(timeout: .now() + timeout)

        if waitResult == .timedOut {
            return .failure(NSError(
                domain: "ScriptTimeout",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Script execution exceeded \(timeout)s"]
            ))
        }

        return result ?? .failure(NSError(
            domain: "ScriptEngine",
            code: -3,
            userInfo: [NSLocalizedDescriptionKey: "Unknown execution error"]
        ))
    }
}

// MARK: - Procedural Generation

func generateFBMNoise(scale: Double, octaves: Int, lacunarity: Double) -> [UInt8] {
    let size = 256
    var data = [UInt8](repeating: 0, count: size * size)

    for y in 0..<size {
        for x in 0..<size {
            var value: Float = 0
            var amplitude: Float = 1
            var frequency: Float = Float(scale)
            var maxValue: Float = 0

            for _ in 0..<min(octaves, 8) {
                let nx = Float(x) * frequency / Float(size)
                let ny = Float(y) * frequency / Float(size)
                value += amplitude * perlinNoise(nx, ny)
                maxValue += amplitude
                amplitude *= 0.5
                frequency *= Float(lacunarity)
            }

            let normalized = (value / maxValue + 1) * 0.5
            data[y * size + x] = UInt8(max(0, min(255, normalized * 255)))
        }
    }

    return data
}

func generateSphere(radius: Double) -> String {
    let lats = 32
    let lons = 32
    var obj = "# Generated Sphere\n"
    var vertexCount = 0

    for i in 0...lats {
        let lat = Float(i) / Float(lats) * .pi
        let sinLat = sin(lat)
        let cosLat = cos(lat)

        for j in 0...lons {
            let lon = Float(j) / Float(lons) * 2 * .pi
            let sinLon = sin(lon)
            let cosLon = cos(lon)

            let x = Float(radius) * sinLat * cosLon
            let y = Float(radius) * cosLat
            let z = Float(radius) * sinLat * sinLon

            obj += "v \(x) \(y) \(z)\n"
            vertexCount += 1
        }
    }

    for i in 0..<lats {
        for j in 0..<lons {
            let a = i * (lons + 1) + j + 1
            let b = a + lons + 1

            obj += "f \(a) \(b) \(a+1)\n"
            obj += "f \(b) \(b+1) \(a+1)\n"
        }
    }

    return obj
}

func generateFMSynth(ratio: Double, index: Double, duration: Double) -> String {
    let sampleRate = 44100.0
    let samples = Int(duration * sampleRate)
    var audio = [Float]()

    let carFreq: Float = 440
    let modFreq = Float(ratio) * carFreq
    let modIndex = Float(index)

    for i in 0..<samples {
        let t = Float(i) / Float(sampleRate)
        let modulation = modIndex * sin(2 * .pi * modFreq * t)
        let sample = sin(2 * .pi * carFreq * t + modulation)
        audio.append(sample * 0.3)
    }

    return "FM \(samples) samples"
}

// Simple Perlin noise implementation
func perlinNoise(_ x: Float, _ y: Float) -> Float {
    let xi = Int(floor(x)) & 255
    let yi = Int(floor(y)) & 255
    let xf = x - floor(x)
    let yf = y - floor(y)

    let u = fade(xf)
    let v = fade(yf)

    let p = permutation()
    let n00 = grad(p[p[xi] + yi], xf, yf)
    let n10 = grad(p[p[xi + 1] + yi], xf - 1, yf)
    let n01 = grad(p[p[xi] + yi + 1], xf, yf - 1)
    let n11 = grad(p[p[xi + 1] + yi + 1], xf - 1, yf - 1)

    let nx0 = mix(n00, n10, u)
    let nx1 = mix(n01, n11, u)
    return mix(nx0, nx1, v)
}

func fade(_ t: Float) -> Float {
    return t * t * t * (t * (t * 6 - 15) + 10)
}

func mix(_ a: Float, _ b: Float, _ t: Float) -> Float {
    return a + (b - a) * t
}

func grad(_ hash: Int, _ x: Float, _ y: Float) -> Float {
    let h = hash & 15
    let u = h < 8 ? x : y
    let v = h < 8 ? y : x
    return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v)
}

func permutation() -> [Int] {
    let p = [151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225,
             140, 36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23, 190, 6, 148,
             247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32,
             57, 177, 33, 88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175,
             74, 165, 71, 134, 139, 48, 27, 166, 102, 143, 97, 109, 190, 40, 129, 76,
             280, 192, 187, 100, 234, 90, 206, 186, 182, 218, 85, 89, 141, 41, 4, 46,
             236, 64, 43, 160, 259, 60, 248, 130, 204, 44, 7, 108, 197, 128, 216, 130,
             130, 131, 94, 25, 226, 92, 65, 132, 131, 94, 25, 226, 92, 65, 132, 131,
             94, 25, 226, 92, 65, 132, 131, 94, 25, 226, 92, 65, 132, 131, 94, 25,
             226, 92, 65, 132, 131, 94, 25, 226, 92, 65, 132, 131, 94, 25, 226, 92,
             65, 132, 131, 94, 25, 226, 92, 65, 132, 131, 94, 25, 226, 92, 65, 132]
    return p + p
}
