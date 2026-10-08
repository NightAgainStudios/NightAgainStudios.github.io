import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
let inPath = CommandLine.arguments[1], outPath = CommandLine.arguments[2]
let tol = Double(CommandLine.arguments[3]) ?? 22       // full transparency within this distance
let soft = Double(CommandLine.arguments[4]) ?? 26      // fade to opaque by tol+soft
guard let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: inPath) as CFURL, nil),
      let img = CGImageSourceCreateImageAtIndex(src, 0, nil) else { print("no image"); exit(1) }
let w = img.width, h = img.height
let cs = CGColorSpaceCreateDeviceRGB()
var data = [UInt8](repeating: 0, count: w * h * 4)
let ctx = CGContext(data: &data, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4, space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.draw(img, in: CGRect(x: 0, y: 0, width: w, height: h))
// the ground: the mean of the four corners
var bg = [0.0, 0.0, 0.0]
for (x, y) in [(4,4), (w-5,4), (4,h-5), (w-5,h-5)] { let i = (y*w+x)*4; bg[0] += Double(data[i]); bg[1] += Double(data[i+1]); bg[2] += Double(data[i+2]) }
bg = bg.map { $0 / 4 }
var cleared = 0
for y in 0..<h { for x in 0..<w {
    let i = (y*w+x)*4
    let d = sqrt(pow(Double(data[i])-bg[0],2) + pow(Double(data[i+1])-bg[1],2) + pow(Double(data[i+2])-bg[2],2))
    var a: Double = 1
    if d <= tol { a = 0 } else if d < tol + soft { a = (d - tol) / soft }
    if a < 1 {
        // un-premultiply is a no-op here (source was opaque); premultiply by the new alpha
        data[i] = UInt8(Double(data[i]) * a); data[i+1] = UInt8(Double(data[i+1]) * a); data[i+2] = UInt8(Double(data[i+2]) * a); data[i+3] = UInt8(255 * a)
        if a == 0 { cleared += 1 }
    }
}}
let out = ctx.makeImage()!
let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: outPath) as CFURL, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(dest, out, nil); CGImageDestinationFinalize(dest)
print(String(format: "ground #%02X%02X%02X cleared %.1f%%", Int(bg[0]), Int(bg[1]), Int(bg[2]), 100.0 * Double(cleared) / Double(w*h)))
