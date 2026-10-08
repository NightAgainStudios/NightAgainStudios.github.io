import Foundation
import CoreGraphics
import ImageIO
let url = URL(fileURLWithPath: CommandLine.arguments[1])
let src = CGImageSourceCreateWithURL(url as CFURL, nil)!
let img = CGImageSourceCreateImageAtIndex(src, 0, nil)!
let w = img.width, h = img.height
let cs = CGColorSpaceCreateDeviceRGB()
let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w*4, space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.draw(img, in: CGRect(x: 0, y: 0, width: w, height: h))
let p = ctx.data!.assumingMemoryBound(to: UInt8.self)
func a(_ x: Int, _ y: Int) -> Int { Int(p[(y*w + x)*4 + 3]) }
print("size \(w)x\(h)")
for (x,y) in [(5,5),(w-6,5),(5,h-6),(w-6,h-6),(w/2,20),(20,h/2),(w/2,h/2),(w/8,h/8),(w/2, h*3/4), (w/2, h-40)] { print("alpha@(\(x),\(y)) = \(a(x,y))") }
var opaque = 0, clear = 0, mid = 0
for y in stride(from: 0, to: h, by: 4) { for x in stride(from: 0, to: w, by: 4) { let v = a(x,y); if v == 0 { clear += 1 } else if v == 255 { opaque += 1 } else { mid += 1 } } }
print("clear \(clear) opaque \(opaque) mid \(mid)")
var minX = w, maxX = 0, minY = h, maxY = 0
for y in 0..<h { for x in 0..<w { if a(x,y) > 8 { if x < minX { minX = x }; if x > maxX { maxX = x }; if y < minY { minY = y }; if y > maxY { maxY = y } } } }
print("bbox x \(minX)...\(maxX) (left gap \(minX), right gap \(w-1-maxX))  y \(minY)...\(maxY) (top gap \(minY), bottom gap \(h-1-maxY))")
// the wordmark rows: the lowest 30% of the bbox
var wmMinX = w, wmMaxX = 0
let yStart = minY + (maxY - minY) * 70 / 100
for y in yStart...maxY { for x in 0..<w { if a(x,y) > 8 { if x < wmMinX { wmMinX = x }; if x > wmMaxX { wmMaxX = x } } } }
print("wordmark rows x \(wmMinX)...\(wmMaxX) centre \((wmMinX+wmMaxX)/2) vs canvas centre \(w/2)")
var mkMinX = w, mkMaxX = 0
for y in minY..<yStart { for x in 0..<w { if a(x,y) > 8 { if x < mkMinX { mkMinX = x }; if x > mkMaxX { mkMaxX = x } } } }
print("monogram rows x \(mkMinX)...\(mkMaxX) centre \((mkMinX+mkMaxX)/2) vs canvas centre \(w/2)")
