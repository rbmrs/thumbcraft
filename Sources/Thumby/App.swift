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

    var strokeWidth: CGFloat {
        switch self {
        case .minimal: 0
        case .catchy: -7
        case .modern: -2.5
        }
    }

    var alignment: TextAlignment {
        .center
    }
}

private struct EditorState {
    var image: NSImage?
    var imageURL: URL?
    var headline = "YOUR TEXT"
    var profile: TextProfile = .catchy
    var fontSize: Double = TextProfile.catchy.defaultSize
    var textColor = Color(nsColor: TextProfile.catchy.color)
    var pictureOutlineColor = Color(nsColor: TextProfile.catchy.color)
    var pictureOutlineMatchesText = true
    var pictureOutlineWidth: Double = 18
    var textPosition = CGPoint(x: 0.5, y: 0.54)
    var textBoxWidth: Double = 0.72
    var isUppercase = true
    var exportStatus = ""

    mutating func apply(_ profile: TextProfile) {
        self.profile = profile
        fontSize = profile.defaultSize
        textColor = Color(nsColor: profile.color)
        pictureOutlineColor = Color(nsColor: profile.color)
        pictureOutlineMatchesText = true
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
                    text: renderedHeadline,
                    profile: state.profile,
                    fontSize: state.fontSize,
                    color: state.textColor,
                    pictureOutlineColor: activePictureOutlineColor,
                    pictureOutlineWidth: state.pictureOutlineWidth,
                    normalizedPosition: $state.textPosition,
                    boxWidth: state.textBoxWidth
                )
                .padding(28)
            } else {
                DropZone(isTargeted: isTargeted) {
                    openImage()
                }
                .padding(32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onDrop(of: [.fileURL, .image], isTargeted: $isTargeted, perform: handleDrop)
    }

    private var controlsPane: some View {
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

            Spacer()
        }
        .padding(24)
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

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                    let url = urlFromProviderItem(item)
                    if let url, let image = NSImage(contentsOf: url) {
                        DispatchQueue.main.async {
                            state.image = image
                            state.imageURL = url
                            state.exportStatus = ""
                        }
                    }
                }
                return true
            }

            if provider.canLoadObject(ofClass: NSImage.self) {
                _ = provider.loadObject(ofClass: NSImage.self) { image, _ in
                    guard let image = image as? NSImage else { return }
                    DispatchQueue.main.async {
                        state.image = image
                        state.imageURL = nil
                        state.exportStatus = ""
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
            state.image = image
            state.imageURL = url
            state.exportStatus = ""
        }
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
                text: renderedHeadline,
                profile: state.profile,
                fontSize: state.fontSize,
                color: NSColor(state.textColor),
                pictureOutlineColor: NSColor(activePictureOutlineColor),
                pictureOutlineWidth: state.pictureOutlineWidth,
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
    let openAction: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 62, weight: .medium))
                .foregroundStyle(isTargeted ? Color.accentColor : Color.secondary)
            VStack(spacing: 6) {
                Text("Drop an image")
                    .font(.system(size: 34, weight: .bold))
                Text("Add thumbnail text, tweak the profile, drag it into place, export PNG.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Button {
                openAction()
            } label: {
                Label("Choose Image", systemImage: "folder")
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

private struct ImageCanvas: View {
    let image: NSImage
    let text: String
    let profile: TextProfile
    let fontSize: Double
    let color: Color
    let pictureOutlineColor: Color
    let pictureOutlineWidth: Double
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

                Rectangle()
                    .strokeBorder(pictureOutlineColor, lineWidth: previewLineWidth(imageRect: imageRect))
                    .frame(width: imageRect.width, height: imageRect.height)
                    .position(x: imageRect.midX, y: imageRect.midY)

                DraggableTextOverlay(
                    text: text,
                    profile: profile,
                    fontSize: previewFontSize(imageRect: imageRect),
                    color: color,
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

    private func previewLineWidth(imageRect: CGRect) -> Double {
        let base = max(image.pixelSize.width, image.pixelSize.height)
        guard base > 0 else { return pictureOutlineWidth }
        return pictureOutlineWidth * (max(imageRect.width, imageRect.height) / base)
    }
}

private struct DraggableTextOverlay: View {
    let text: String
    let profile: TextProfile
    let fontSize: Double
    let color: Color
    let boxWidth: Double
    let imageRect: CGRect
    @Binding var normalizedPosition: CGPoint

    var body: some View {
        ZStack {
            if profile.strokeWidth < 0 {
                ForEach(Array(outlineOffsets(width: abs(profile.strokeWidth)).enumerated()), id: \.offset) { _, offset in
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
        text: String,
        profile: TextProfile,
        fontSize: Double,
        color: NSColor,
        pictureOutlineColor: NSColor,
        pictureOutlineWidth: Double,
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
        drawPictureOutline(color: pictureOutlineColor, width: pictureOutlineWidth, canvas: canvas)

        drawText(
            text,
            profile: profile,
            fontSize: fontSize,
            color: color,
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

    private static func drawText(
        _ text: String,
        profile: TextProfile,
        fontSize: Double,
        color: NSColor,
        normalizedPosition: CGPoint,
        boxWidth: Double,
        canvas: CGRect
    ) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineBreakMode = .byWordWrapping

        let font = NSFont(name: profile.fontName, size: fontSize) ?? .systemFont(ofSize: fontSize, weight: .heavy)
        let strokeWidth = profile.strokeWidth
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph,
            .strokeColor: NSColor.black.withAlphaComponent(strokeWidth < 0 ? 0.9 : 0),
            .strokeWidth: strokeWidth,
            .shadow: shadow(for: profile, fontSize: fontSize)
        ]

        let attributed = NSAttributedString(string: text, attributes: attributes)
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
        attributed.draw(with: rect, options: [.usesLineFragmentOrigin, .usesFontLeading])
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
