import SwiftUI
import AppKit
import UniformTypeIdentifiers

@main
struct ThumbyApp: App {
    var body: some Scene {
        WindowGroup {
            EditorView()
                .frame(minWidth: 1100, minHeight: 720)
        }
        .windowStyle(.hiddenTitleBar)
    }
}

private enum TextProfile: String, CaseIterable, Identifiable {
    case minimal = "Minimal"
    case catchy = "Catchy"
    case modern = "Modern"

    var id: String { rawValue }

    var defaultSize: Double {
        switch self {
        case .minimal: 72
        case .catchy: 112
        case .modern: 88
        }
    }

    var fontName: String {
        switch self {
        case .minimal: "Helvetica Neue Medium"
        case .catchy: "Impact"
        case .modern: "Avenir Next Heavy"
        }
    }

    var color: NSColor {
        switch self {
        case .minimal: .white
        case .catchy: NSColor(calibratedRed: 1.0, green: 0.86, blue: 0.05, alpha: 1.0)
        case .modern: NSColor(calibratedRed: 0.33, green: 0.95, blue: 0.74, alpha: 1.0)
        }
    }

    var shadowOpacity: CGFloat {
        switch self {
        case .minimal: 0.38
        case .catchy: 0.76
        case .modern: 0.45
        }
    }

    var textOutlineWidth: Double {
        switch self {
        case .minimal: 0
        case .catchy: 7
        case .modern: 2.5
        }
    }

    var alignment: TextAlignment {
        .center
    }
}

private struct ImageLayer: Identifiable {
    let id: UUID
    var image: NSImage
    var name: String
    var position: CGPoint
    var width: Double
    var opacity: Double

    init(image: NSImage, name: String, width: Double) {
        self.id = UUID()
        self.image = image
        self.name = name
        self.position = CGPoint(x: 0.5, y: 0.5)
        self.width = width
        self.opacity = 1
    }
}

private struct EditorState {
    var image: NSImage?
    var imageURL: URL?
    var imageLayers: [ImageLayer] = []
    var selectedImageLayerID: UUID?
    var headline = "YOUR TEXT"
    var profile: TextProfile = .catchy
    var fontSize: Double = TextProfile.catchy.defaultSize
    var textColor = Color(nsColor: TextProfile.catchy.color)
    var textOutlineWidth: Double = TextProfile.catchy.textOutlineWidth
    var pictureOutlineColor = Color(nsColor: TextProfile.catchy.color)
    var pictureOutlineMatchesText = true
    var pictureOutlineWidth: Double = 18
    var arrowEnabled = false
    var arrowColor = Color(nsColor: TextProfile.catchy.color)
    var arrowOutlineWidth: Double = 9
    var arrowPosition = CGPoint(x: 0.68, y: 0.38)
    var arrowSize: Double = 260
    var arrowRotation: Double = -8
    var textPosition = CGPoint(x: 0.5, y: 0.54)
    var textBoxWidth: Double = 0.72
    var isUppercase = true
    var exportStatus = ""

    mutating func apply(_ profile: TextProfile) {
        self.profile = profile
        fontSize = profile.defaultSize
        textColor = Color(nsColor: profile.color)
        textOutlineWidth = profile.textOutlineWidth
        pictureOutlineColor = Color(nsColor: profile.color)
        pictureOutlineMatchesText = true
        arrowColor = Color(nsColor: profile.color)
        isUppercase = profile != .minimal
        switch profile {
        case .minimal:
            textPosition = CGPoint(x: 0.32, y: 0.76)
            textBoxWidth = 0.56
        case .catchy:
            textPosition = CGPoint(x: 0.5, y: 0.58)
            textBoxWidth = 0.76
        case .modern:
            textPosition = CGPoint(x: 0.35, y: 0.66)
            textBoxWidth = 0.62
        }
    }

    mutating func addArrow() {
        arrowEnabled = true
        arrowColor = textColor
        arrowOutlineWidth = 9
        arrowPosition = CGPoint(x: 0.68, y: 0.38)
        arrowSize = 260
        arrowRotation = -8
    }
}

struct EditorView: View {
    @State private var state = EditorState()
    @State private var isTargeted = false

    var body: some View {
        HStack(spacing: 0) {
            canvasPane
            if state.image != nil {
                controlsPane
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .animation(.snappy(duration: 0.22), value: state.image != nil)
    }

    private var canvasPane: some View {
        ZStack {
            if let image = state.image {
                ImageCanvas(
                    image: image,
                    imageLayers: $state.imageLayers,
                    selectedImageLayerID: $state.selectedImageLayerID,
                    text: renderedHeadline,
                    profile: state.profile,
                    fontSize: state.fontSize,
                    color: state.textColor,
                    textOutlineWidth: state.textOutlineWidth,
                    pictureOutlineColor: activePictureOutlineColor,
                    pictureOutlineWidth: state.pictureOutlineWidth,
                    arrowEnabled: state.arrowEnabled,
                    arrowColor: state.arrowColor,
                    arrowOutlineWidth: state.arrowOutlineWidth,
                    arrowSize: state.arrowSize,
                    arrowRotation: state.arrowRotation,
                    arrowPosition: $state.arrowPosition,
                    normalizedPosition: $state.textPosition,
                    boxWidth: state.textBoxWidth
                )
                .padding(28)
            } else {
                DropZone(isTargeted: isTargeted, pasteAction: pasteImageFromClipboard) {
                    openImage()
                }
                .padding(32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onDrop(of: [.fileURL, .image], isTargeted: $isTargeted, perform: handleDrop)
        .background {
            ClipboardPasteMonitor(isEnabled: true, pasteAction: pasteImageFromClipboard)
        }
    }

    private var controlsPane: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Thumby")
                        .font(.system(size: 24, weight: .bold))
                    Text(state.imageURL?.lastPathComponent ?? "Untitled image")
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                Button {
                    openImage()
                } label: {
                    Label("Replace", systemImage: "photo")
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Text")
                    .font(.headline)
                TextEditor(text: $state.headline)
                    .font(.system(size: 18, weight: .semibold))
                    .scrollContentBackground(.hidden)
                    .frame(height: 92)
                    .padding(8)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Profile")
                    .font(.headline)
                Picker("Profile", selection: Binding(
                    get: { state.profile },
                    set: { state.apply($0) }
                )) {
                    ForEach(TextProfile.allCases) { profile in
                        Text(profile.rawValue).tag(profile)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 14) {
                Toggle("Uppercase", isOn: $state.isUppercase)

                LabeledContent("Size") {
                    HStack {
                        Slider(value: $state.fontSize, in: 28...180, step: 1)
                        Text("\(Int(state.fontSize))")
                            .monospacedDigit()
                            .frame(width: 40, alignment: .trailing)
                    }
                }

                LabeledContent("Width") {
                    HStack {
                        Slider(value: $state.textBoxWidth, in: 0.24...0.95, step: 0.01)
                        Text("\(Int(state.textBoxWidth * 100))%")
                            .monospacedDigit()
                            .frame(width: 48, alignment: .trailing)
                    }
                }

                ColorPicker("Color", selection: $state.textColor, supportsOpacity: true)

                LabeledContent("Text outline") {
                    HStack {
                        Slider(value: $state.textOutlineWidth, in: 0...18, step: 0.5)
                        Text(state.textOutlineWidth.formatted(.number.precision(.fractionLength(0...1))))
                            .monospacedDigit()
                            .frame(width: 40, alignment: .trailing)
                    }
                }

                Divider()

                LabeledContent("Picture outline") {
                    HStack {
                        Slider(value: $state.pictureOutlineWidth, in: 0...80, step: 1)
                        Text("\(Int(state.pictureOutlineWidth))")
                            .monospacedDigit()
                            .frame(width: 40, alignment: .trailing)
                    }
                }

                Toggle("Match text color", isOn: $state.pictureOutlineMatchesText)

                ColorPicker("Outline color", selection: $state.pictureOutlineColor, supportsOpacity: true)
                    .disabled(state.pictureOutlineMatchesText)
                    .opacity(state.pictureOutlineMatchesText ? 0.55 : 1)
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Image layers")
                        .font(.headline)
                    Spacer()
                    Button {
                        _ = pasteImageFromClipboard()
                    } label: {
                        Label("Paste Layer", systemImage: "doc.on.clipboard")
                    }
                }

                if let index = selectedImageLayerIndex {
                    Text(state.imageLayers[index].name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    LabeledContent("Size") {
                        HStack {
                            Slider(
                                value: Binding(
                                    get: { state.imageLayers[index].width },
                                    set: { state.imageLayers[index].width = $0 }
                                ),
                                in: 40...maxLayerWidth,
                                step: 5
                            )
                            Text("\(Int(state.imageLayers[index].width))")
                                .monospacedDigit()
                                .frame(width: 48, alignment: .trailing)
                        }
                    }

                    Button(role: .destructive) {
                        removeSelectedImageLayer()
                    } label: {
                        Label("Remove Layer", systemImage: "trash")
                    }
                } else {
                    Text("Drop or paste an image onto the thumbnail to add a draggable logo or overlay.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Attention arrow")
                        .font(.headline)
                    Spacer()
                    Button {
                        if state.arrowEnabled {
                            state.arrowEnabled = false
                        } else {
                            state.addArrow()
                        }
                    } label: {
                        Label(state.arrowEnabled ? "Remove" : "Add Arrow", systemImage: state.arrowEnabled ? "trash" : "arrow.turn.down.right")
                    }
                }

                if state.arrowEnabled {
                    LabeledContent("Size") {
                        HStack {
                            Slider(value: $state.arrowSize, in: 120...520, step: 5)
                            Text("\(Int(state.arrowSize))")
                                .monospacedDigit()
                                .frame(width: 44, alignment: .trailing)
                        }
                    }

                    LabeledContent("Rotation") {
                        HStack {
                            Slider(value: $state.arrowRotation, in: -180...180, step: 1)
                            Text("\(Int(state.arrowRotation))°")
                                .monospacedDigit()
                                .frame(width: 48, alignment: .trailing)
                        }
                    }

                    LabeledContent("Outline") {
                        HStack {
                            Slider(value: $state.arrowOutlineWidth, in: 0...32, step: 1)
                            Text("\(Int(state.arrowOutlineWidth))")
                                .monospacedDigit()
                                .frame(width: 44, alignment: .trailing)
                        }
                    }

                    ColorPicker("Arrow color", selection: $state.arrowColor, supportsOpacity: true)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                Button {
                    exportPNG()
                } label: {
                    Label("Export PNG", systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.large)
                .buttonStyle(.borderedProminent)

                Text(state.exportStatus)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .frame(minHeight: 34, alignment: .topLeading)
            }

            Spacer(minLength: 0)
            }
            .padding(24)
        }
        .frame(width: 360)
        .background(.regularMaterial)
    }

    private var renderedHeadline: String {
        let trimmed = state.headline.trimmingCharacters(in: .whitespacesAndNewlines)
        let value = trimmed.isEmpty ? "YOUR TEXT" : trimmed
        return state.isUppercase ? value.uppercased() : value
    }

    private var activePictureOutlineColor: Color {
        state.pictureOutlineMatchesText ? state.textColor : state.pictureOutlineColor
    }

    private var selectedImageLayerIndex: Int? {
        guard let id = state.selectedImageLayerID else { return nil }
        return state.imageLayers.firstIndex { $0.id == id }
    }

    private var maxLayerWidth: Double {
        max(120, (state.image?.pixelSize.width ?? 800) * 1.5)
    }

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                    let url = urlFromProviderItem(item)
                    if let url, let image = NSImage(contentsOf: url) {
                        DispatchQueue.main.async {
                            receiveImage(image, sourceURL: url)
                        }
                    }
                }
                return true
            }

            if provider.canLoadObject(ofClass: NSImage.self) {
                _ = provider.loadObject(ofClass: NSImage.self) { image, _ in
                    guard let image = image as? NSImage else { return }
                    DispatchQueue.main.async {
                        receiveImage(image, sourceURL: nil)
                    }
                }
                return true
            }
        }
        return false
    }

    private func openImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if panel.runModal() == .OK, let url = panel.url {
            loadImage(from: url)
        }
    }

    private func loadImage(from url: URL) {
        guard let image = NSImage(contentsOf: url) else { return }
        DispatchQueue.main.async {
            setBaseImage(image, sourceURL: url)
        }
    }

    @discardableResult
    private func pasteImageFromClipboard() -> Bool {
        let pasteboard = NSPasteboard.general
        if let image = NSImage(pasteboard: pasteboard) {
            receiveImage(image, sourceURL: nil)
            return true
        }

        let options: [NSPasteboard.ReadingOptionKey: Any] = [.urlReadingFileURLsOnly: true]
        guard let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: options) as? [URL] else {
            return false
        }

        for url in urls {
            if let image = NSImage(contentsOf: url) {
                receiveImage(image, sourceURL: url)
                return true
            }
        }
        return false
    }

    private func receiveImage(_ image: NSImage, sourceURL: URL?) {
        if state.image == nil {
            setBaseImage(image, sourceURL: sourceURL)
        } else {
            addImageLayer(image, name: sourceURL?.lastPathComponent ?? "Pasted image")
        }
    }

    private func setBaseImage(_ image: NSImage, sourceURL: URL?) {
        state.image = image
        state.imageURL = sourceURL
        state.imageLayers = []
        state.selectedImageLayerID = nil
        state.exportStatus = ""
    }

    private func addImageLayer(_ image: NSImage, name: String) {
        let baseWidth = state.image?.pixelSize.width ?? 1280
        let layerWidth = max(80, min(baseWidth * 0.26, image.pixelSize.width > 0 ? image.pixelSize.width : baseWidth * 0.26))
        let layer = ImageLayer(image: image, name: name, width: layerWidth)
        state.imageLayers.append(layer)
        state.selectedImageLayerID = layer.id
        state.exportStatus = "Added \(name)"
    }

    private func removeSelectedImageLayer() {
        guard let id = state.selectedImageLayerID else { return }
        state.imageLayers.removeAll { $0.id == id }
        state.selectedImageLayerID = state.imageLayers.last?.id
    }

    private func exportPNG() {
        guard let image = state.image else { return }
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = defaultExportName()
        if panel.runModal() != .OK { return }
        guard let url = panel.url else { return }

        do {
            let data = try ThumbnailRenderer.renderPNG(
                image: image,
                imageLayers: state.imageLayers,
                text: renderedHeadline,
                profile: state.profile,
                fontSize: state.fontSize,
                color: NSColor(state.textColor),
                textOutlineWidth: state.textOutlineWidth,
                pictureOutlineColor: NSColor(activePictureOutlineColor),
                pictureOutlineWidth: state.pictureOutlineWidth,
                arrowEnabled: state.arrowEnabled,
                arrowColor: NSColor(state.arrowColor),
                arrowOutlineWidth: state.arrowOutlineWidth,
                arrowSize: state.arrowSize,
                arrowRotation: state.arrowRotation,
                arrowPosition: state.arrowPosition,
                normalizedPosition: state.textPosition,
                boxWidth: state.textBoxWidth
            )
            try data.write(to: url, options: .atomic)
            state.exportStatus = "Exported \(url.lastPathComponent)"
        } catch {
            state.exportStatus = "Export failed: \(error.localizedDescription)"
        }
    }

    private func defaultExportName() -> String {
        let base = state.imageURL?.deletingPathExtension().lastPathComponent ?? "thumbnail"
        return "\(base)-thumb.png"
    }
}

private struct DropZone: View {
    let isTargeted: Bool
    let pasteAction: () -> Bool
    let openAction: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 62, weight: .medium))
                .foregroundStyle(isTargeted ? Color.accentColor : Color.secondary)
            VStack(spacing: 6) {
                Text("Drop or paste an image")
                    .font(.system(size: 34, weight: .bold))
                Text("Drag a file here, press Command-V with an image on your clipboard, or choose one from disk.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            HStack(spacing: 12) {
                Button {
                    openAction()
                } label: {
                    Label("Choose Image", systemImage: "folder")
                }

                Button {
                    _ = pasteAction()
                } label: {
                    Label("Paste Image", systemImage: "doc.on.clipboard")
                }
            }
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(isTargeted ? Color.accentColor.opacity(0.13) : Color(nsColor: .controlBackgroundColor))
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(isTargeted ? Color.accentColor : Color.secondary.opacity(0.35), style: StrokeStyle(lineWidth: 2, dash: [10, 8]))
        }
    }
}

private struct ClipboardPasteMonitor: NSViewRepresentable {
    let isEnabled: Bool
    let pasteAction: () -> Bool

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        context.coordinator.installMonitor()
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.isEnabled = isEnabled
        context.coordinator.pasteAction = pasteAction
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(isEnabled: isEnabled, pasteAction: pasteAction)
    }

    static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
        coordinator.removeMonitor()
    }

    @MainActor
    final class Coordinator {
        var isEnabled: Bool
        var pasteAction: () -> Bool
        private var monitor: Any?

        init(isEnabled: Bool, pasteAction: @escaping () -> Bool) {
            self.isEnabled = isEnabled
            self.pasteAction = pasteAction
        }

        func installMonitor() {
            guard monitor == nil else { return }
            monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                guard let self, self.isEnabled, event.modifierFlags.contains(.command), event.charactersIgnoringModifiers == "v" else {
                    return event
                }
                if NSApp.keyWindow?.firstResponder is NSTextView {
                    return event
                }
                return self.pasteAction() ? nil : event
            }
        }

        func removeMonitor() {
            if let monitor {
                NSEvent.removeMonitor(monitor)
                self.monitor = nil
            }
        }
    }
}

private struct ImageCanvas: View {
    let image: NSImage
    @Binding var imageLayers: [ImageLayer]
    @Binding var selectedImageLayerID: UUID?
    let text: String
    let profile: TextProfile
    let fontSize: Double
    let color: Color
    let textOutlineWidth: Double
    let pictureOutlineColor: Color
    let pictureOutlineWidth: Double
    let arrowEnabled: Bool
    let arrowColor: Color
    let arrowOutlineWidth: Double
    let arrowSize: Double
    let arrowRotation: Double
    @Binding var arrowPosition: CGPoint
    @Binding var normalizedPosition: CGPoint
    let boxWidth: Double

    var body: some View {
        GeometryReader { proxy in
            let imageRect = fittedRect(imageSize: image.pixelSize, in: proxy.size)
            ZStack(alignment: .topLeading) {
                Color(nsColor: .textBackgroundColor)
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageRect.width, height: imageRect.height)
                    .position(x: imageRect.midX, y: imageRect.midY)
                    .shadow(color: .black.opacity(0.16), radius: 18, y: 8)

                ForEach($imageLayers) { $layer in
                    DraggableImageLayerOverlay(
                        layer: $layer,
                        isSelected: selectedImageLayerID == layer.id,
                        imageRect: imageRect,
                        scale: previewScale(imageRect: imageRect)
                    ) {
                        selectedImageLayerID = layer.id
                    }
                }

                Rectangle()
                    .strokeBorder(pictureOutlineColor, lineWidth: previewLineWidth(imageRect: imageRect))
                    .frame(width: imageRect.width, height: imageRect.height)
                    .position(x: imageRect.midX, y: imageRect.midY)

                if arrowEnabled {
                    DraggableArrowOverlay(
                        color: arrowColor,
                        outlineWidth: previewArrowOutlineWidth(imageRect: imageRect),
                        size: previewArrowSize(imageRect: imageRect),
                        rotation: arrowRotation,
                        imageRect: imageRect,
                        normalizedPosition: $arrowPosition
                    )
                }

                DraggableTextOverlay(
                    text: text,
                    profile: profile,
                    fontSize: previewFontSize(imageRect: imageRect),
                    color: color,
                    textOutlineWidth: previewTextOutlineWidth(imageRect: imageRect),
                    boxWidth: imageRect.width * boxWidth,
                    imageRect: imageRect,
                    normalizedPosition: $normalizedPosition
                )
            }
            .coordinateSpace(name: "canvas")
        }
    }

    private func previewFontSize(imageRect: CGRect) -> Double {
        let base = max(image.pixelSize.width, image.pixelSize.height)
        guard base > 0 else { return fontSize }
        return fontSize * (max(imageRect.width, imageRect.height) / base)
    }

    private func previewScale(imageRect: CGRect) -> Double {
        let base = max(image.pixelSize.width, image.pixelSize.height)
        guard base > 0 else { return 1 }
        return max(imageRect.width, imageRect.height) / base
    }

    private func previewLineWidth(imageRect: CGRect) -> Double {
        let base = max(image.pixelSize.width, image.pixelSize.height)
        guard base > 0 else { return pictureOutlineWidth }
        return pictureOutlineWidth * (max(imageRect.width, imageRect.height) / base)
    }

    private func previewTextOutlineWidth(imageRect: CGRect) -> Double {
        let base = max(image.pixelSize.width, image.pixelSize.height)
        guard base > 0 else { return textOutlineWidth }
        return textOutlineWidth * (max(imageRect.width, imageRect.height) / base)
    }

    private func previewArrowSize(imageRect: CGRect) -> Double {
        let base = max(image.pixelSize.width, image.pixelSize.height)
        guard base > 0 else { return arrowSize }
        return arrowSize * (max(imageRect.width, imageRect.height) / base)
    }

    private func previewArrowOutlineWidth(imageRect: CGRect) -> Double {
        let base = max(image.pixelSize.width, image.pixelSize.height)
        guard base > 0 else { return arrowOutlineWidth }
        return arrowOutlineWidth * (max(imageRect.width, imageRect.height) / base)
    }
}

private struct DraggableImageLayerOverlay: View {
    @Binding var layer: ImageLayer
    let isSelected: Bool
    let imageRect: CGRect
    let scale: Double
    let selectAction: () -> Void

    var body: some View {
        let previewWidth = layer.width * scale
        let aspectRatio = layer.image.pixelSize.width > 0 ? layer.image.pixelSize.height / layer.image.pixelSize.width : 1
        let previewHeight = previewWidth * aspectRatio

        Image(nsImage: layer.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .opacity(layer.opacity)
            .frame(width: previewWidth, height: previewHeight)
            .overlay {
                if isSelected {
                    Rectangle()
                        .strokeBorder(.white, lineWidth: 2)
                        .shadow(color: .black.opacity(0.8), radius: 2)
                }
            }
            .contentShape(Rectangle())
            .position(position(in: imageRect))
            .gesture(
                DragGesture(coordinateSpace: .named("canvas"))
                    .onChanged { value in
                        selectAction()
                        let x = ((value.location.x - imageRect.minX) / imageRect.width).clamped(to: 0...1)
                        let y = ((value.location.y - imageRect.minY) / imageRect.height).clamped(to: 0...1)
                        layer.position = CGPoint(x: x, y: y)
                    }
            )
            .onTapGesture {
                selectAction()
            }
    }

    private func position(in rect: CGRect) -> CGPoint {
        CGPoint(
            x: rect.minX + rect.width * layer.position.x,
            y: rect.minY + rect.height * layer.position.y
        )
    }
}

private struct DraggableArrowOverlay: View {
    let color: Color
    let outlineWidth: Double
    let size: Double
    let rotation: Double
    let imageRect: CGRect
    @Binding var normalizedPosition: CGPoint

    var body: some View {
        CurvedArrowView(color: color, outlineColor: .black.opacity(0.9), outlineWidth: outlineWidth, lineWidth: max(4, size * 0.085))
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rotation))
            .contentShape(Rectangle())
            .position(position(in: imageRect))
            .gesture(
                DragGesture(coordinateSpace: .named("canvas"))
                    .onChanged { value in
                        let x = ((value.location.x - imageRect.minX) / imageRect.width).clamped(to: 0...1)
                        let y = ((value.location.y - imageRect.minY) / imageRect.height).clamped(to: 0...1)
                        normalizedPosition = CGPoint(x: x, y: y)
                    }
            )
    }

    private func position(in rect: CGRect) -> CGPoint {
        CGPoint(
            x: rect.minX + rect.width * normalizedPosition.x,
            y: rect.minY + rect.height * normalizedPosition.y
        )
    }
}

private struct CurvedArrowView: View {
    let color: Color
    let outlineColor: Color
    let outlineWidth: Double
    let lineWidth: Double

    var body: some View {
        ZStack {
            if outlineWidth > 0 {
                CurvedArrowShaft()
                    .stroke(outlineColor, style: StrokeStyle(lineWidth: lineWidth + outlineWidth * 2, lineCap: .round, lineJoin: .round))
                CurvedArrowHead()
                    .stroke(outlineColor, style: StrokeStyle(lineWidth: outlineWidth * 2, lineJoin: .round))
                CurvedArrowHead()
                    .fill(outlineColor)
            }

            CurvedArrowShaft()
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            CurvedArrowHead()
                .fill(color)
        }
    }
}

private struct CurvedArrowShaft: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let points = arrowPoints(in: rect)
        path.move(to: points.tail)
        path.addCurve(to: points.neck, control1: points.control1, control2: points.control2)
        return path
    }
}

private struct CurvedArrowHead: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let points = arrowPoints(in: rect)
        path.move(to: points.tip)
        path.addLine(to: points.headLeft)
        path.addLine(to: points.headRight)
        path.closeSubpath()
        return path
    }
}

private struct ArrowPoints {
    let tail: CGPoint
    let control1: CGPoint
    let control2: CGPoint
    let neck: CGPoint
    let tip: CGPoint
    let headLeft: CGPoint
    let headRight: CGPoint
}

private func arrowPoints(in rect: CGRect) -> ArrowPoints {
    let side = min(rect.width, rect.height)
    let drawingRect = rect.insetBy(dx: side * 0.08, dy: side * 0.08)
    func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(
            x: drawingRect.minX + drawingRect.width * x,
            y: drawingRect.minY + drawingRect.height * y
        )
    }

    let tail = point(0.14, 0.74)
    let control1 = point(0.26, 0.24)
    let control2 = point(0.60, 0.20)
    let neck = point(0.75, 0.41)
    let tip = point(0.88, 0.55)
    let tangent = normalizedVector(from: control2, to: tip)
    let normal = CGPoint(x: -tangent.y, y: tangent.x)
    let headLength = side * 0.22
    let headWidth = side * 0.20
    let base = CGPoint(x: tip.x - tangent.x * headLength, y: tip.y - tangent.y * headLength)
    let headLeft = CGPoint(x: base.x + normal.x * headWidth / 2, y: base.y + normal.y * headWidth / 2)
    let headRight = CGPoint(x: base.x - normal.x * headWidth / 2, y: base.y - normal.y * headWidth / 2)

    return ArrowPoints(
        tail: tail,
        control1: control1,
        control2: control2,
        neck: neck,
        tip: tip,
        headLeft: headLeft,
        headRight: headRight
    )
}

private func normalizedVector(from start: CGPoint, to end: CGPoint) -> CGPoint {
    let dx = end.x - start.x
    let dy = end.y - start.y
    let length = max(0.0001, sqrt(dx * dx + dy * dy))
    return CGPoint(x: dx / length, y: dy / length)
}

private struct DraggableTextOverlay: View {
    let text: String
    let profile: TextProfile
    let fontSize: Double
    let color: Color
    let textOutlineWidth: Double
    let boxWidth: Double
    let imageRect: CGRect
    @Binding var normalizedPosition: CGPoint

    var body: some View {
        ZStack {
            if textOutlineWidth > 0 {
                ForEach(Array(outlineOffsets(width: textOutlineWidth).enumerated()), id: \.offset) { _, offset in
                    Text(text)
                        .font(.custom(profile.fontName, size: fontSize))
                        .fontWeight(.heavy)
                        .foregroundStyle(.black.opacity(0.9))
                        .multilineTextAlignment(profile.alignment)
                        .lineLimit(4)
                        .minimumScaleFactor(0.3)
                        .offset(x: offset.width, y: offset.height)
                }
            }

            Text(text)
                .font(.custom(profile.fontName, size: fontSize))
                .fontWeight(.heavy)
                .foregroundStyle(color)
                .multilineTextAlignment(profile.alignment)
                .lineLimit(4)
                .minimumScaleFactor(0.3)
        }
        .shadow(color: .black.opacity(profile.shadowOpacity), radius: max(2, fontSize * 0.08), x: 0, y: max(2, fontSize * 0.045))
        .frame(width: boxWidth, alignment: alignment)
        .contentShape(Rectangle())
        .position(position(in: imageRect))
        .gesture(
            DragGesture(coordinateSpace: .named("canvas"))
                .onChanged { value in
                    let x = ((value.location.x - imageRect.minX) / imageRect.width).clamped(to: 0...1)
                    let y = ((value.location.y - imageRect.minY) / imageRect.height).clamped(to: 0...1)
                    normalizedPosition = CGPoint(x: x, y: y)
                }
        )
    }

    private var alignment: Alignment {
        switch profile.alignment {
        case .leading: .leading
        case .trailing: .trailing
        default: .center
        }
    }

    private func position(in rect: CGRect) -> CGPoint {
        CGPoint(
            x: rect.minX + rect.width * normalizedPosition.x,
            y: rect.minY + rect.height * normalizedPosition.y
        )
    }

    private func outlineOffsets(width: CGFloat) -> [CGSize] {
        [
            CGSize(width: width, height: 0),
            CGSize(width: -width, height: 0),
            CGSize(width: 0, height: width),
            CGSize(width: 0, height: -width),
            CGSize(width: width * 0.7, height: width * 0.7),
            CGSize(width: -width * 0.7, height: -width * 0.7),
            CGSize(width: width * 0.7, height: -width * 0.7),
            CGSize(width: -width * 0.7, height: width * 0.7)
        ]
    }
}

private enum ThumbnailRenderer {
    enum RenderError: Error {
        case missingBitmap
        case pngEncodingFailed
    }

    static func renderPNG(
        image: NSImage,
        imageLayers: [ImageLayer],
        text: String,
        profile: TextProfile,
        fontSize: Double,
        color: NSColor,
        textOutlineWidth: Double,
        pictureOutlineColor: NSColor,
        pictureOutlineWidth: Double,
        arrowEnabled: Bool,
        arrowColor: NSColor,
        arrowOutlineWidth: Double,
        arrowSize: Double,
        arrowRotation: Double,
        arrowPosition: CGPoint,
        normalizedPosition: CGPoint,
        boxWidth: Double
    ) throws -> Data {
        let size = image.pixelSize
        guard size.width > 0, size.height > 0 else { throw RenderError.missingBitmap }

        let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(size.width),
            pixelsHigh: Int(size.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )
        guard let bitmap else { throw RenderError.missingBitmap }

        NSGraphicsContext.saveGraphicsState()
        let context = NSGraphicsContext(bitmapImageRep: bitmap)
        NSGraphicsContext.current = context

        let canvas = CGRect(origin: .zero, size: size)
        NSColor.clear.setFill()
        canvas.fill()
        image.draw(in: canvas, from: .zero, operation: .copy, fraction: 1.0)
        drawImageLayers(imageLayers, canvas: canvas)
        drawPictureOutline(color: pictureOutlineColor, width: pictureOutlineWidth, canvas: canvas)
        if arrowEnabled {
            drawAttentionArrow(
                color: arrowColor,
                outlineColor: NSColor.black.withAlphaComponent(0.9),
                outlineWidth: arrowOutlineWidth,
                size: arrowSize,
                rotation: arrowRotation,
                normalizedPosition: arrowPosition,
                canvas: canvas
            )
        }

        drawText(
            text,
            profile: profile,
            fontSize: fontSize,
            color: color,
            textOutlineWidth: textOutlineWidth,
            normalizedPosition: normalizedPosition,
            boxWidth: boxWidth,
            canvas: canvas
        )

        NSGraphicsContext.restoreGraphicsState()

        guard let data = bitmap.representation(using: .png, properties: [:]) else {
            throw RenderError.pngEncodingFailed
        }
        return data
    }

    private static func drawPictureOutline(color: NSColor, width: Double, canvas: CGRect) {
        guard width > 0 else { return }
        let lineWidth = CGFloat(width)
        let inset = lineWidth / 2
        let path = NSBezierPath(rect: canvas.insetBy(dx: inset, dy: inset))
        path.lineWidth = lineWidth
        color.setStroke()
        path.stroke()
    }

    private static func drawImageLayers(_ imageLayers: [ImageLayer], canvas: CGRect) {
        for layer in imageLayers {
            let imageSize = layer.image.pixelSize
            guard imageSize.width > 0, imageSize.height > 0, layer.width > 0 else { continue }
            let height = layer.width * (imageSize.height / imageSize.width)
            let center = CGPoint(
                x: canvas.minX + canvas.width * layer.position.x,
                y: canvas.maxY - canvas.height * layer.position.y
            )
            let rect = CGRect(
                x: center.x - layer.width / 2,
                y: center.y - height / 2,
                width: layer.width,
                height: height
            )
            layer.image.draw(in: rect, from: .zero, operation: .sourceOver, fraction: layer.opacity)
        }
    }

    private static func drawAttentionArrow(
        color: NSColor,
        outlineColor: NSColor,
        outlineWidth: Double,
        size: Double,
        rotation: Double,
        normalizedPosition: CGPoint,
        canvas: CGRect
    ) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        let localRect = CGRect(x: -size / 2, y: -size / 2, width: size, height: size)
        let points = arrowPoints(in: localRect)
        let lineWidth = max(4, size * 0.085)
        let cgColor = (color.usingColorSpace(.deviceRGB) ?? color).cgColor
        let cgOutlineColor = (outlineColor.usingColorSpace(.deviceRGB) ?? outlineColor).cgColor

        context.saveGState()
        context.translateBy(x: 0, y: canvas.height)
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: canvas.width * normalizedPosition.x, y: canvas.height * normalizedPosition.y)
        context.rotate(by: CGFloat(rotation * .pi / 180))

        if outlineWidth > 0 {
            context.setStrokeColor(cgOutlineColor)
            context.setLineWidth(lineWidth + outlineWidth * 2)
            context.setLineCap(.round)
            context.setLineJoin(.round)
            context.beginPath()
            context.move(to: points.tail)
            context.addCurve(to: points.neck, control1: points.control1, control2: points.control2)
            context.strokePath()

            context.setFillColor(cgOutlineColor)
            context.beginPath()
            context.move(to: points.tip)
            context.addLine(to: points.headLeft)
            context.addLine(to: points.headRight)
            context.closePath()
            context.fillPath()

            context.setStrokeColor(cgOutlineColor)
            context.setLineWidth(outlineWidth * 2)
            context.setLineJoin(.round)
            context.beginPath()
            context.move(to: points.tip)
            context.addLine(to: points.headLeft)
            context.addLine(to: points.headRight)
            context.closePath()
            context.strokePath()
        }

        context.setStrokeColor(cgColor)
        context.setLineWidth(lineWidth)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.beginPath()
        context.move(to: points.tail)
        context.addCurve(to: points.neck, control1: points.control1, control2: points.control2)
        context.strokePath()

        context.setFillColor(cgColor)
        context.beginPath()
        context.move(to: points.tip)
        context.addLine(to: points.headLeft)
        context.addLine(to: points.headRight)
        context.closePath()
        context.fillPath()

        context.restoreGState()
    }

    private static func drawText(
        _ text: String,
        profile: TextProfile,
        fontSize: Double,
        color: NSColor,
        textOutlineWidth: Double,
        normalizedPosition: CGPoint,
        boxWidth: Double,
        canvas: CGRect
    ) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineBreakMode = .byWordWrapping

        let font = NSFont(name: profile.fontName, size: fontSize) ?? .systemFont(ofSize: fontSize, weight: .heavy)
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph,
            .shadow: shadow(for: profile, fontSize: fontSize)
        ]
        let outlineAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.black.withAlphaComponent(0.9),
            .paragraphStyle: paragraph,
            .shadow: shadow(for: profile, fontSize: fontSize)
        ]

        let attributed = NSAttributedString(string: text, attributes: baseAttributes)
        let width = canvas.width * boxWidth
        let bounding = attributed.boundingRect(
            with: CGSize(width: width, height: canvas.height),
            options: [.usesLineFragmentOrigin, .usesFontLeading]
        )
        let anchor = CGPoint(
            x: canvas.minX + canvas.width * normalizedPosition.x,
            y: canvas.maxY - canvas.height * normalizedPosition.y
        )
        let rect = CGRect(
            x: anchor.x - width / 2,
            y: anchor.y - bounding.height / 2,
            width: width,
            height: ceil(bounding.height) + fontSize * 0.18
        )

        if textOutlineWidth > 0 {
            let outline = NSAttributedString(string: text, attributes: outlineAttributes)
            for offset in outlineOffsets(width: CGFloat(textOutlineWidth)) {
                outline.draw(
                    with: rect.offsetBy(dx: offset.width, dy: offset.height),
                    options: [.usesLineFragmentOrigin, .usesFontLeading]
                )
            }
        }

        attributed.draw(with: rect, options: [.usesLineFragmentOrigin, .usesFontLeading])
    }

    private static func outlineOffsets(width: CGFloat) -> [CGSize] {
        [
            CGSize(width: width, height: 0),
            CGSize(width: -width, height: 0),
            CGSize(width: 0, height: width),
            CGSize(width: 0, height: -width),
            CGSize(width: width * 0.7, height: width * 0.7),
            CGSize(width: -width * 0.7, height: -width * 0.7),
            CGSize(width: width * 0.7, height: -width * 0.7),
            CGSize(width: -width * 0.7, height: width * 0.7)
        ]
    }

    private static func shadow(for profile: TextProfile, fontSize: Double) -> NSShadow {
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(profile.shadowOpacity)
        shadow.shadowBlurRadius = max(2, fontSize * 0.08)
        shadow.shadowOffset = CGSize(width: 0, height: -max(2, fontSize * 0.045))
        return shadow
    }
}

private func urlFromProviderItem(_ item: NSSecureCoding?) -> URL? {
    if let url = item as? URL {
        return url
    }
    if let data = item as? Data {
        return URL(dataRepresentation: data, relativeTo: nil)
    }
    if let string = item as? String {
        return URL(string: string)
    }
    return nil
}

private func fittedRect(imageSize: CGSize, in container: CGSize) -> CGRect {
    guard imageSize.width > 0, imageSize.height > 0, container.width > 0, container.height > 0 else {
        return .zero
    }
    let scale = min(container.width / imageSize.width, container.height / imageSize.height)
    let size = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
    return CGRect(
        x: (container.width - size.width) / 2,
        y: (container.height - size.height) / 2,
        width: size.width,
        height: size.height
    )
}

private extension NSImage {
    var pixelSize: CGSize {
        if let rep = representations.max(by: { ($0.pixelsWide * $0.pixelsHigh) < ($1.pixelsWide * $1.pixelsHigh) }) {
            return CGSize(width: rep.pixelsWide, height: rep.pixelsHigh)
        }
        return size
    }
}

private extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
