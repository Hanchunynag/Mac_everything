import AppKit
import Foundation

struct IconSize {
    let filename: String
    let pixels: Int
}

let outputDirectory = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "Resources/Assets.xcassets/AppIcon.appiconset")
try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

let sizes = [
    IconSize(filename: "icon_16x16.png", pixels: 16),
    IconSize(filename: "icon_16x16@2x.png", pixels: 32),
    IconSize(filename: "icon_32x32.png", pixels: 32),
    IconSize(filename: "icon_32x32@2x.png", pixels: 64),
    IconSize(filename: "icon_128x128.png", pixels: 128),
    IconSize(filename: "icon_128x128@2x.png", pixels: 256),
    IconSize(filename: "icon_256x256.png", pixels: 256),
    IconSize(filename: "icon_256x256@2x.png", pixels: 512),
    IconSize(filename: "icon_512x512.png", pixels: 512),
    IconSize(filename: "icon_512x512@2x.png", pixels: 1024)
]

for size in sizes {
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size.pixels,
        pixelsHigh: size.pixels,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        throw NSError(domain: "IconGeneration", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create canvas for \(size.filename)"])
    }

    bitmap.size = NSSize(width: size.pixels, height: size.pixels)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)

    let rect = NSRect(x: 0, y: 0, width: size.pixels, height: size.pixels)
    NSColor.clear.setFill()
    rect.fill()

    drawIcon(in: rect)

    NSGraphicsContext.restoreGraphicsState()

    guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "IconGeneration", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to render \(size.filename)"])
    }

    try pngData.write(to: outputDirectory.appendingPathComponent(size.filename))
}

func drawIcon(in rect: NSRect) {
    let scale = rect.width / 1024.0

    func r(_ value: CGFloat) -> CGFloat {
        value * scale
    }

    let background = NSBezierPath(roundedRect: rect.insetBy(dx: r(40), dy: r(40)), xRadius: r(210), yRadius: r(210))
    let gradient = NSGradient(colors: [
        NSColor(red: 0.08, green: 0.44, blue: 0.95, alpha: 1.0),
        NSColor(red: 0.02, green: 0.18, blue: 0.55, alpha: 1.0)
    ])
    gradient?.draw(in: background, angle: -35)

    NSColor(red: 0.83, green: 0.92, blue: 1.0, alpha: 0.20).setStroke()
    background.lineWidth = r(18)
    background.stroke()

    let fileRect = NSRect(x: r(245), y: r(245), width: r(420), height: r(520))
    let filePath = NSBezierPath(roundedRect: fileRect, xRadius: r(54), yRadius: r(54))
    NSColor.white.withAlphaComponent(0.93).setFill()
    filePath.fill()

    let foldPath = NSBezierPath()
    foldPath.move(to: NSPoint(x: fileRect.maxX - r(138), y: fileRect.maxY))
    foldPath.line(to: NSPoint(x: fileRect.maxX, y: fileRect.maxY - r(138)))
    foldPath.line(to: NSPoint(x: fileRect.maxX - r(118), y: fileRect.maxY - r(138)))
    foldPath.curve(
        to: NSPoint(x: fileRect.maxX - r(138), y: fileRect.maxY),
        controlPoint1: NSPoint(x: fileRect.maxX - r(132), y: fileRect.maxY - r(108)),
        controlPoint2: NSPoint(x: fileRect.maxX - r(138), y: fileRect.maxY - r(48))
    )
    foldPath.close()
    NSColor(red: 0.72, green: 0.84, blue: 1.0, alpha: 1.0).setFill()
    foldPath.fill()

    NSColor(red: 0.12, green: 0.31, blue: 0.68, alpha: 0.22).setFill()
    for index in 0..<4 {
        let y = fileRect.maxY - r(210 + CGFloat(index) * 86)
        let line = NSBezierPath(roundedRect: NSRect(x: fileRect.minX + r(82), y: y, width: r(index == 3 ? 185 : 260), height: r(22)), xRadius: r(11), yRadius: r(11))
        line.fill()
    }

    let lensRect = NSRect(x: r(455), y: r(200), width: r(330), height: r(330))
    let lens = NSBezierPath(ovalIn: lensRect)
    NSColor(red: 0.03, green: 0.11, blue: 0.30, alpha: 0.34).setFill()
    lens.fill()

    NSColor.white.withAlphaComponent(0.96).setStroke()
    lens.lineWidth = r(58)
    lens.stroke()

    let handle = NSBezierPath()
    handle.move(to: NSPoint(x: r(704), y: r(284)))
    handle.line(to: NSPoint(x: r(830), y: r(158)))
    handle.lineCapStyle = .round
    NSColor.white.withAlphaComponent(0.96).setStroke()
    handle.lineWidth = r(62)
    handle.stroke()

    let shine = NSBezierPath()
    shine.move(to: NSPoint(x: r(542), y: r(432)))
    shine.curve(
        to: NSPoint(x: r(630), y: r(506)),
        controlPoint1: NSPoint(x: r(558), y: r(484)),
        controlPoint2: NSPoint(x: r(594), y: r(506))
    )
    shine.lineCapStyle = .round
    NSColor.white.withAlphaComponent(0.48).setStroke()
    shine.lineWidth = r(30)
    shine.stroke()
}
