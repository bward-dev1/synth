import Foundation
import SynthCore

// Signed Distance Field (SDF) primitive
protocol SDFPrimitive {
    func distance(at point: SIMD3<Float>) -> Float
}

// Basic SDF shapes
struct SDFSphere: SDFPrimitive {
    let center: SIMD3<Float>
    let radius: Float

    func distance(at point: SIMD3<Float>) -> Float {
        length(point - center) - radius
    }
}

struct SDFBox: SDFPrimitive {
    let center: SIMD3<Float>
    let size: SIMD3<Float>

    func distance(at point: SIMD3<Float>) -> Float {
        let q = abs(point - center) - size / 2
        return length(max(q, .zero)) + min(max(q.x, max(q.y, q.z)), 0)
    }
}

// SDF operations (union, smooth union, subtract, intersect)
struct SDFUnion: SDFPrimitive {
    let a: SDFPrimitive
    let b: SDFPrimitive

    func distance(at point: SIMD3<Float>) -> Float {
        min(a.distance(at: point), b.distance(at: point))
    }
}

struct SDFSmoothUnion: SDFPrimitive {
    let a: SDFPrimitive
    let b: SDFPrimitive
    let k: Float

    func distance(at point: SIMD3<Float>) -> Float {
        let da = a.distance(at: point)
        let db = b.distance(at: point)
        let h = max(k - abs(da - db), 0) / k
        return min(da, db) - h * h * k / 4
    }
}

class SDFMeshGenerator {
    // Marching cubes to convert SDF to mesh
    func generateMesh(from sdf: SDFPrimitive, gridResolution: Int) -> MeshData? {
        // TODO: Implement marching cubes algorithm to extract mesh from SDF
        // Returns a MeshData struct with vertices, indices, normals
        return nil
    }
}

// Mesh data structure (for export to OBJ/USDZ)
struct MeshData {
    var vertices: [SIMD3<Float>] = []
    var indices: [UInt32] = []
    var normals: [SIMD3<Float>] = []

    func toOBJ() -> String {
        var obj = "# Synth generated mesh\n"
        for vertex in vertices {
            obj += "v \(vertex.x) \(vertex.y) \(vertex.z)\n"
        }
        for normal in normals {
            obj += "vn \(normal.x) \(normal.y) \(normal.z)\n"
        }
        var i = 0
        while i < indices.count {
            let i0 = indices[i] + 1
            let i1 = indices[i + 1] + 1
            let i2 = indices[i + 2] + 1
            obj += "f \(i0)//\(i0) \(i1)//\(i1) \(i2)//\(i2)\n"
            i += 3
        }
        return obj
    }
}
