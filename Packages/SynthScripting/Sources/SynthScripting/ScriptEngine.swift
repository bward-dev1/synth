import Foundation
import JavaScriptCore
import SynthCore

protocol ScriptExportDelegate: AnyObject {
    func texture_fbmNoise(scale: Double, octaves: Int, lacunarity: Double) -> String
    func texture_domainWarp(input: String, strength: Double) -> String
    func mesh_sphere(radius: Double) -> String
    func mesh_lsystem(axiom: String, generations: Int) -> String
    func audio_fmSynth(ratio: Double, index: Double) -> String
    func param(name: String, min: Double, max: Double, defaultValue: Double) -> Void
}

@objc protocol TextureExports: JSExport {
    func fbmNoise(scale: Double, octaves: Int, lacunarity: Double) -> String
    func domainWarp(input: String, strength: Double) -> String
}

@objc protocol MeshExports: JSExport {
    func sphere(radius: Double) -> String
    func lsystem(axiom: String, generations: Int) -> String
}

@objc protocol AudioExports: JSExport {
    func fmSynth(ratio: Double, index: Double) -> String
}

@objc protocol ParamExports: JSExport {
    func param(name: String, min: Double, max: Double) -> Double
}

class TextureAPI: NSObject, TextureExports {
    weak var delegate: ScriptExportDelegate?

    func fbmNoise(scale: Double, octaves: Int, lacunarity: Double) -> String {
        delegate?.texture_fbmNoise(scale: scale, octaves: octaves, lacunarity: lacunarity) ?? ""
    }

    func domainWarp(input: String, strength: Double) -> String {
        delegate?.texture_domainWarp(input: input, strength: strength) ?? ""
    }
}

class MeshAPI: NSObject, MeshExports {
    weak var delegate: ScriptExportDelegate?

    func sphere(radius: Double) -> String {
        delegate?.mesh_sphere(radius: radius) ?? ""
    }

    func lsystem(axiom: String, generations: Int) -> String {
        delegate?.mesh_lsystem(axiom: axiom, generations: generations) ?? ""
    }
}

class AudioAPI: NSObject, AudioExports {
    weak var delegate: ScriptExportDelegate?

    func fmSynth(ratio: Double, index: Double) -> String {
        delegate?.audio_fmSynth(ratio: ratio, index: index) ?? ""
    }
}

class ParamAPI: NSObject, ParamExports {
    weak var delegate: ScriptExportDelegate?

    func param(name: String, min: Double, max: Double) -> Double {
        // Placeholder: returns default value (middle of range)
        (min + max) / 2.0
    }
}

class ScriptEngine {
    private let context: JSContext
    private let queue = DispatchQueue(label: "com.synth.scripting", qos: .userInitiated)
    private let timeout: TimeInterval = 2.0
    weak var delegate: ScriptExportDelegate?

    var consoleOutput: [String] = []

    init() {
        self.context = JSContext()

        // Set up console capture
        self.context.setObject(
            { args in
                let output = args.map { $0?.description ?? "undefined" }.joined(separator: " ")
                print(output)
            } as @convention(block) (JSValue) -> Void,
            forKeyedSubscript: NSString(string: "console")
        )

        // Set up APIs
        let textureAPI = TextureAPI()
        textureAPI.delegate = delegate
        context.setObject(textureAPI, forKeyedSubscript: NSString(string: "texture"))

        let meshAPI = MeshAPI()
        meshAPI.delegate = delegate
        context.setObject(meshAPI, forKeyedSubscript: NSString(string: "mesh"))

        let audioAPI = AudioAPI()
        audioAPI.delegate = delegate
        context.setObject(audioAPI, forKeyedSubscript: NSString(string: "audio"))

        let paramAPI = ParamAPI()
        paramAPI.delegate = delegate
        context.setObject(paramAPI, forKeyedSubscript: NSString(string: "param"))
    }

    func execute(_ script: String, timeout: TimeInterval = 2.0) -> Result<JSValue?, Error> {
        var result: Result<JSValue?, Error>?
        let semaphore = DispatchSemaphore(value: 0)

        queue.async {
            let jsResult = self.context.evaluateScript(script)

            if let error = self.context.exception {
                result = .failure(NSError(
                    domain: "JSError",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: error.toString() ?? "Unknown error"]
                ))
            } else {
                result = .success(jsResult)
            }

            semaphore.signal()
        }

        // Wait with timeout
        let waitResult = semaphore.wait(timeout: .now() + timeout)

        if waitResult == .timedOut {
            // Timeout — script took too long
            return .failure(NSError(
                domain: "ScriptTimeout",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Script execution exceeded \(timeout)s timeout"]
            ))
        }

        return result ?? .failure(NSError(
            domain: "ScriptEngine",
            code: -3,
            userInfo: [NSLocalizedDescriptionKey: "Unknown execution error"]
        ))
    }
}
