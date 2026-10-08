// Cuts the monogram (the mark above the wordmark) out of the transparent logo and writes the
// favicon set. Usage: favicon <transparent-logo.png> <out-dir>
import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let inURL = URL(fileURLWithPath: CommandLine.arguments[1])
let outDir = CommandLine.arguments[2]
let src = CGImageSourceCreateWithURL(inURL as CFURL, nil)!
let img = CGImageSourceCreateImageAtIndex(src, 0, nil)!
let w = img.width, h = img.height
let cs = CGColorSpaceCreateDeviceRGB()
let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4, space: cs,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.draw(img, in: CGRect(x: 0, y: 0, width: w, height: h))
let p = ctx.data!.assumingMemoryBound(to: UInt8.self)
func alpha(_ x: Int, _ y: Int) -> Int { Int(p[(y * w + x) * 4 + 3]) }   // bitmap rows: y=0 is the TOP
func rowHasInk(_ y: Int) -> Bool { for x in 0..<w where alpha(x, y) > 8 { return true }; return false }

// Scan from the top row down: the first inked row starts the monogram; the first empty row after
// it ends the monogram (the gap above the wordmark).
var top = -1, bottom = -1
var y = 0
while y < h && !rowHasInk(y) { y += 1 }
top = y
while y < h && rowHasInk(y) { y += 1 }
bottom = y - 1
var left = w, right = 0
for yy in top...bottom { for x in 0..<w where alpha(x, yy) > 8 { left = min(left, x); right = max(right, x) } }
let bw = right - left + 1, bh = bottom - top + 1
print("monogram rows \(top)...\(bottom)  cols \(left)...\(right)  → \(bw)x\(bh)")

// A square cell around the monogram with a margin of 10 % of the longer side.
let side = Int(Double(max(bw, bh)) * 1.20)
let cx = left + bw / 2, cy = top + bh / 2
let cell = CGRect(x: cx - side / 2, y: cy - side / 2, width: side, height: side)
let full = ctx.makeImage()!
let crop = full.cropping(to: cell)!

func write(_ image: CGImage, _ name: String) {
    let url = URL(fileURLWithPath: outDir).appendingPathComponent(name)
    let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, image, nil)
    CGImageDestinationFinalize(dest)
    print("wrote \(name) \(image.width)x\(image.height)")
}
func render(_ size: Int, ground: CGColor?) -> CGImage {
    let c = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: size * 4, space: cs,
                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    c.interpolationQuality = .high
    c.draw(crop, in: CGRect(x: 0, y: 0, width: size, height: size))
    // The square cell reaches into the wordmark below the monogram; erase those rows (the cell's
    // top-left origin is bitmap space, the context's is bottom-left, hence the flip).
    let belowFrac = Double(bottom + 1 - Int(cell.minY)) / Double(side)          // monogram ends here (0…1 from the top)
    c.clear(CGRect(x: 0, y: 0, width: Double(size), height: Double(size) * (1 - belowFrac)))
    if let g = ground {
        c.setBlendMode(.destinationOver); c.setFillColor(g)
        c.fill(CGRect(x: 0, y: 0, width: size, height: size)); c.setBlendMode(.normal)
    }
    return c.makeImage()!
}
let night = CGColor(colorSpace: cs, components: [0x0A / 255.0, 0x0C / 255.0, 0x12 / 255.0, 1])!
write(render(512, ground: nil), "favicon-512.png")
write(render(192, ground: nil), "favicon-192.png")
write(render(32, ground: nil), "favicon-32.png")
write(render(16, ground: nil), "favicon-16.png")
write(render(180, ground: night), "apple-touch-icon.png")   // iOS fills transparency with black; give it the page's night instead
