import SwiftUI
import UIKit
import SynthCore
import SynthScripting
import SynthTexture
import SynthMesh
import SynthAudio

struct EditorView: View {
    @State private var scriptText = """
    // Welcome to Synth!
    // Write JavaScript code to generate textures, meshes, and audio.

    // Example: Generate an fBm noise texture
    let tex = texture.fbmNoise(scale: 2.0, octaves: 4, lacunarity: 2.0);

    // Example: Generate a simple mesh
    let mesh = mesh.sphere(radius: 1.0);
    """

    @State private var isRunning = false
    @State private var consoleOutput: [String] = []
    @State private var selectedTab: EditorTab = .texture
    @State private var parameters: [Parameter] = []

    var body: some View {
        VStack(spacing: 0) {
            // Top toolbar
            HStack {
                Button(action: runScript) {
                    Label("Run", systemImage: "play.fill")
                }
                .disabled(isRunning)

                Spacer()

                Picker("Module", selection: $selectedTab) {
                    ForEach(EditorTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding()
            .background(Color(.systemBackground))

            // Code editor
            ZStack {
                TextEditor(text: $scriptText)
                    .font(.monospaced(.system(size: 13))())
                    .background(Color(.systemGray6))
                    .padding(8)
            }
            .frame(maxHeight: 250)

            // Parameters panel (auto-generated from param() calls)
            if !parameters.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Parameters")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach($parameters) { $param in
                        HStack {
                            Text(param.name)
                                .frame(width: 100, alignment: .leading)
                            Slider(value: $param.value, in: param.min...param.max)
                            Text(String(format: "%.2f", param.value))
                                .frame(width: 50, alignment: .trailing)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 8)
                .background(Color(.systemGray5))
            }

            // Preview area
            VStack {
                Text("Preview")
                    .font(.headline)
                    .padding()

                PreviewView(selectedTab: selectedTab)
                    .frame(maxHeight: .infinity)
            }
            .background(Color(.systemBackground))

            // Console
            VStack(alignment: .leading, spacing: 4) {
                Text("Console")
                    .font(.headline)
                    .padding(.horizontal)

                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(consoleOutput, id: \.self) { line in
                            Text(line)
                                .font(.system(size: 11, weight: .regular, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(4)
                }
            }
            .frame(height: 100)
            .background(Color(.systemGray6))
        }
    }

    private func runScript() {
        isRunning = true
        let engine = ScriptEngine()

        DispatchQueue.global(qos: .userInitiated).async {
            let result = engine.execute(scriptText, timeout: 2.0)

            DispatchQueue.main.async {
                isRunning = false
                switch result {
                case .success(let jsValue):
                    consoleOutput.append("✓ Script executed")
                    if let output = jsValue?.description {
                        consoleOutput.append(output)
                    }
                case .failure(let error):
                    consoleOutput.append("✗ Error: \(error.localizedDescription)")
                }
            }
        }
    }
}

enum EditorTab: String, CaseIterable {
    case texture = "Texture"
    case mesh = "Mesh"
    case audio = "Audio"
}

struct Parameter {
    var name: String
    var value: Double
    var min: Double
    var max: Double
}

struct PreviewView: View {
    let selectedTab: EditorTab

    var body: some View {
        ZStack {
            Color(.systemGray6)

            VStack {
                switch selectedTab {
                case .texture:
                    Image(systemName: "square.fill.pattern.grid.2x2")
                        .font(.system(size: 64))
                        .foregroundColor(.gray)
                    Text("Texture Preview")

                case .mesh:
                    Image(systemName: "cube.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.gray)
                    Text("Mesh Preview")

                case .audio:
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.gray)
                    Text("Audio Preview")
                }
            }
        }
    }
}

// Simple monospaced font extension
extension Font {
    static func monospaced(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .monospaced)
    }
}

#Preview {
    EditorView()
}
