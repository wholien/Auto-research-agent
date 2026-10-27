import AppKit

// Finder coordinates and the layout in create_dmg.sh use points, not pixels.
// Finder does not scale picture backgrounds with the window. Extend the canvas
// to cover large windows; keep the installation layout anchored at the top left.
let width = 3840
let height = 2160
let layoutWidth = 660
let destination = URL(fileURLWithPath: CommandLine.arguments[1])
var representations: [NSBitmapImageRep] = []
for scale in [1, 2] {
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width * scale,
        pixelsHigh: height * scale, bitsPerSample: 8, samplesPerPixel: 4,
        hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
        bytesPerRow: 0, bitsPerPixel: 0)!
    bitmap.size = NSSize(width: width, height: height)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    let canvas = NSRect(x: 0, y: 0, width: width, height: height)
    NSColor(srgbRed: 0.09, green: 0.08, blue: 0.13, alpha: 1).setFill()
    canvas.fill()
    NSGradient(starting: NSColor(srgbRed: 0.09, green: 0.08, blue: 0.13, alpha: 1),
               ending: NSColor(srgbRed: 0.18, green: 0.16, blue: 0.25, alpha: 1))!
        .draw(in: NSRect(x: 0, y: height - 460, width: width, height: 460), angle: 90)

    func centered(_ text: String, top: CGFloat, size: CGFloat, color: NSColor, weight: NSFont.Weight) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: size, weight: weight), .foregroundColor: color
        ]
        let bounds = (text as NSString).size(withAttributes: attributes)
        (text as NSString).draw(at: NSPoint(x: (CGFloat(layoutWidth) - bounds.width) / 2,
            y: CGFloat(height) - top - bounds.height), withAttributes: attributes)
    }
    centered("Auto Research", top: 70, size: 27, color: .white, weight: .semibold)
    centered("Drag to Applications to install", top: 110, size: 16,
             color: NSColor(white: 0.72, alpha: 1), weight: .medium)

    NSColor(srgbRed: 0.69, green: 0.67, blue: 1, alpha: 1).setStroke()
    let arrow = NSBezierPath()
    let y = CGFloat(height) - 235
    arrow.move(to: NSPoint(x: 265, y: y))
    arrow.line(to: NSPoint(x: 395, y: y))
    arrow.move(to: NSPoint(x: 380, y: y + 15))
    arrow.line(to: NSPoint(x: 395, y: y))
    arrow.line(to: NSPoint(x: 380, y: y - 15))
    arrow.lineWidth = 3
    arrow.lineCapStyle = .round
    arrow.lineJoinStyle = .round
    arrow.stroke()
    // Finder uses dark filenames over picture backgrounds, even in Dark Mode.
    // These plates sit behind the real labels; do not bake filenames into the art.
    NSColor(white: 0.86, alpha: 1).setFill()
    for (x, top, plateWidth) in [(80.0, 282.0, 160.0), (430.0, 282.0, 140.0), (265.0, 422.0, 130.0)] {
        let plate = NSRect(x: x, y: Double(height) - top - 30, width: plateWidth, height: 30)
        NSBezierPath(roundedRect: plate, xRadius: 15, yRadius: 15).fill()
    }
    NSGraphicsContext.restoreGraphicsState()
    representations.append(bitmap)
}
// A multi-resolution TIFF keeps text sharp on Retina displays at the same point size.
let data = NSBitmapImageRep.representationOfImageReps(in: representations, using: .tiff, properties: [.compressionMethod: NSBitmapImageRep.TIFFCompression.lzw.rawValue])!
try data.write(to: destination)
