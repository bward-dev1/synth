import Foundation
import Metal

enum DeviceTier {
    case legacy  // A9X, 2GB RAM, no Neural Engine (iPad Pro 9.7)
    case mid     // A12Z, ~6GB RAM, has Neural Engine
    case modern  // M-series, 8GB+, full feature set
}

class DeviceProfile {
    static let shared = DeviceProfile()

    let tier: DeviceTier
    let maxTextureResolution: Int
    let maxMarchingCubesGridResolution: Int
    let maxPolygonCount: Int
    let enableMLModels: Bool
    let audioPolyphony: Int
    let supportsLiveAsYouType: Bool
    let physicalMemory: UInt64

    private init() {
        let memory = ProcessInfo.processInfo.physicalMemory
        self.physicalMemory = memory

        let processorCount = ProcessInfo.processInfo.activeProcessorCount

        // Check for Neural Engine support (A11+, excluding A11 itself which has limited support)
        var hasNeuralEngine = false
        if #available(iOS 14.0, *) {
            if let device = MTLCreateSystemDefaultDevice() {
                hasNeuralEngine = device.supportsFamily(.apple4) || device.supportsFamily(.apple5) ||
                                device.supportsFamily(.apple6) || device.supportsFamily(.apple7) ||
                                device.supportsFamily(.apple8)
            }
        }

        // Determine tier from memory and Neural Engine support
        if memory < 3_000_000_000 { // < 3GB
            self.tier = .legacy
            self.maxTextureResolution = 512
            self.maxMarchingCubesGridResolution = 32
            self.maxPolygonCount = 100_000
            self.enableMLModels = false
            self.audioPolyphony = 4
            self.supportsLiveAsYouType = false
        } else if memory < 7_000_000_000 && !hasNeuralEngine { // 3-7GB, no Neural Engine
            self.tier = .mid
            self.maxTextureResolution = 1024
            self.maxMarchingCubesGridResolution = 64
            self.maxPolygonCount = 500_000
            self.enableMLModels = false
            self.audioPolyphony = 8
            self.supportsLiveAsYouType = true
        } else if hasNeuralEngine && processorCount >= 4 { // Modern with Neural Engine
            self.tier = .modern
            self.maxTextureResolution = 2048
            self.maxMarchingCubesGridResolution = 128
            self.maxPolygonCount = 2_000_000
            self.enableMLModels = true
            self.audioPolyphony = 16
            self.supportsLiveAsYouType = true
        } else {
            // Fallback to mid tier
            self.tier = .mid
            self.maxTextureResolution = 1024
            self.maxMarchingCubesGridResolution = 64
            self.maxPolygonCount = 500_000
            self.enableMLModels = false
            self.audioPolyphony = 8
            self.supportsLiveAsYouType = true
        }
    }
}
