import SwiftUI
import SynthCore
import SynthScripting

struct EditorView: View {
    @State private var scriptText = """
    // Synth v1 — Creative Coding Sketchpad
    // texture.fbmNoise(2.0, 4, 2.0)
    // mesh.sphere(1.0)
    // audio.fmSynth(2.0, 10.0, 2.0)
    """

    @State private var isRunning = false
    @State private var consoleOutput: [String] = []
    @State private var selectedTab: EditorTab = .texture
    @State private var previewImage: UIImage? = nil
    @State private var previewMesh: String = ""
    @State private var showExportSheet = false

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Toolbar
                HStack {
                    Button(action: runScript) {
                        Label("Run", systemImage: "play.fill")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .disabled(isRunning)
                    .buttonStyle(.borderedProminent)

                    Spacer()

                    Button(action: { showExportSheet = true }) {
                        Label("Export", systemImage: "square.and.arrow.up")
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.bordered)

                    Picker("", selection: $selectedTab) {
                        ForEach(EditorTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 200)
                }
                .padding()
                .background(Color(.systemGray6))

                // Editor and Preview Split
                HStack(spacing: 0) {
                    // Code Editor
                    VStack(spacing: 0) {
                        Text("Script").font(.caption).fontWeight(.semibold).frame(maxWidth: .infinity, alignment: .leading).padding(8)
                        TextEditor(text: $scriptText)
                            .font(.system(size: 12, design: .monospaced))
                            .background(Color(.systemBackground))
                            .padding(4)
                        Divider()
                        ConsoleView(output: $consoleOutput)
                    }
                    .frame(maxWidth: .infinity)

                    Divider()

                    // Preview
                    PreviewPane(selectedTab: selectedTab, previewImage: previewImage, previewMesh: previewMesh)
                        .frame(maxWidth: .infinity)
                }

                // Status
                HStack {
                    Text(isRunning ? "Running..." : "Ready")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Synth v1 — \(selectedTab.rawValue)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(8)
                .background(Color(.systemGray6))
            }
        }
        .sheet(isPresented: $showExportSheet) {
            ExportSheet(
                previewImage: previewImage,
                previewMesh: previewMesh,
                selectedTab: selectedTab
            )
        }
    }

    private func runScript() {
        isRunning = true
        consoleOutput.removeAll()

        DispatchQueue.global(qos: .userInitiated).async {
            let engine = ScriptEngine()
            let result = engine.execute(scriptText)

            DispatchQueue.main.async {
                isRunning = false

                switch result {
                case .success(let output):
                    consoleOutput.append("✓ Executed")
                    consoleOutput.append(output)

                    // Generate preview based on selected tab
                    switch selectedTab {
                    case .texture:
                        if let data = engine.lastTextureData {
                            previewImage = createImageFromData(data, size: 256)
                        }
                    case .mesh:
                        previewMesh = engine.lastMeshData ?? ""
                    case .audio:
                        if engine.lastAudioData != nil {
                            consoleOutput.append("🔊 Audio synthesized")
                        }
                    }

                case .failure(let error):
                    consoleOutput.append("✗ \(error.localizedDescription)")
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

struct ConsoleView: View {
    @Binding var output: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Console").font(.caption).fontWeight(.semibold).padding(.horizontal, 8).padding(.top, 4)
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 1) {
                        ForEach(output, id: \.self) { line in
                            Text(line)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                    .padding(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onChange(of: output.count) { _ in
                        if let last = output.last {
                            proxy.scrollTo(last)
                        }
                    }
                }
            }
        }
        .background(Color(.systemGray6))
        .frame(height: 80)
    }
}

struct PreviewPane: View {
    let selectedTab: EditorTab
    let previewImage: UIImage?
    let previewMesh: String

    var body: some View {
        VStack {
            Text("Preview").font(.caption).fontWeight(.semibold)

            switch selectedTab {
            case .texture:
                if let image = previewImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding()
                } else {
                    VStack {
                        Image(systemName: "square.fill.pattern.grid.2x2")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("Run to preview").font(.caption).foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                }

            case .mesh:
                if !previewMesh.isEmpty {
                    ScrollView {
                        Text(previewMesh)
                            .font(.system(size: 9, design: .monospaced))
                            .lineLimit(nil)
                            .padding(4)
                    }
                } else {
                    VStack {
                        Image(systemName: "cube.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("Run to generate").font(.caption).foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                }

            case .audio:
                VStack {
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("Audio synthesis ready").font(.caption).foregroundColor(.secondary)
                }
                .frame(maxHeight: .infinity)
            }
        }
        .background(Color(.systemBackground))
    }
}

struct ExportSheet: View {
    let previewImage: UIImage?
    let previewMesh: String
    let selectedTab: EditorTab
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Export \(selectedTab.rawValue)")
                    .font(.headline)

                switch selectedTab {
                case .texture:
                    if let image = previewImage {
                        HStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                            VStack(alignment: .leading) {
                                Text("Texture").font(.caption).fontWeight(.semibold)
                                Text("256×256 PNG").font(.caption2).foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        ShareLink(
                            item: image,
                            preview: SharePreview("synth-texture.png", image: Image(uiImage: image))
                        ) {
                            Label("Share PNG", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.borderedProminent)
                    }

                case .mesh:
                    if !previewMesh.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Mesh (OBJ)").font(.caption).fontWeight(.semibold)
                            ScrollView {
                                Text(previewMesh)
                                    .font(.system(size: 9, design: .monospaced))
                                    .lineLimit(nil)
                                    .padding(4)
                            }
                            .frame(height: 150)
                            .background(Color(.systemGray6))

                            ShareLink(
                                item: previewMesh,
                                preview: SharePreview("synth-mesh.obj")
                            ) {
                                Label("Share OBJ", systemImage: "square.and.arrow.up")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }

                case .audio:
                    Text("Audio export available after synthesis")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

func createImageFromData(_ data: [UInt8], size: Int) -> UIImage? {
    let width = size
    let height = size
    let bitsPerComponent = 8
    let bitsPerPixel = bitsPerComponent
    let bytesPerRow = width

    guard let provider = CGDataProvider(data: NSData(bytes: data, length: data.count)) else {
        return nil
    }

    guard let cgImage = CGImage(
        width: width,
        height: height,
        bitsPerComponent: bitsPerComponent,
        bitsPerPixel: bitsPerPixel,
        bytesPerRow: bytesPerRow,
        space: CGColorSpaceCreateDeviceGray(),
        bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
        provider: provider,
        decode: nil,
        shouldInterpolate: false,
        intent: .defaultIntent
    ) else {
        return nil
    }

    return UIImage(cgImage: cgImage)
}

#Preview {
    EditorView()
}
