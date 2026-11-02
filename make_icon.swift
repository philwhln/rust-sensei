// Draws the app icon.
// Run: swift make_icon.swift RustSensei/Assets.xcassets/AppIcon.appiconset/AppIcon.png

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let size = 1024
let s = CGFloat(size)
let space = CGColorSpace(name: CGColorSpace.sRGB)!
let ctx = CGContext(
    data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
    space: space, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
)!

func rgb(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(
        srgbRed: CGFloat((hex >> 16) & 0xff) / 255,
        green: CGFloat((hex >> 8) & 0xff) / 255,
        blue: CGFloat(hex & 0xff) / 255,
        alpha: a
    )
}

let bg = CGGradient(
    colorsSpace: space,
    colors: [rgb(0x4a2c22), rgb(0x140e0b)] as CFArray,
    locations: [0, 1]
)!
ctx.drawLinearGradient(
    bg,
    start: CGPoint(x: 0, y: s),
    end: CGPoint(x: 0, y: 0),
    options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
)

ctx.setFillColor(rgb(0xe3843a))
ctx.fillEllipse(in: CGRect(x: 148, y: 148, width: 728, height: 728))

ctx.setStrokeColor(rgb(0x1a100c))
ctx.setLineWidth(92)
ctx.setLineCap(.round)
ctx.setLineJoin(.round)
ctx.move(to: CGPoint(x: 400, y: 700))
ctx.addLine(to: CGPoint(x: 660, y: 512))
ctx.addLine(to: CGPoint(x: 400, y: 324))
ctx.strokePath()

let image = ctx.makeImage()!
let url = URL(fileURLWithPath: CommandLine.arguments[1])
let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(dest, image, nil)
guard CGImageDestinationFinalize(dest) else {
    fputs("could not write icon\n", stderr)
    exit(1)
}
