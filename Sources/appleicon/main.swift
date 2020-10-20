import Foundation
import CoreImage

public enum Idiom: String {
  case iPhone
  case iPad
  case mac
  case watch
}

struct IconInfo {
  let idiom: Idiom
  let size: CGFloat
}

extension CGImage {
  enum BitmapInfo {
    case noneSkipLast(color: CGColor)
  }
  
  func compress(_ info: BitmapInfo? = nil, size: CGSize? = nil) -> CGImage {
    var bitmapInfo = self.alphaInfo.rawValue
    if let info = info {
      switch info {
      case .noneSkipLast(_):
        bitmapInfo = CGImageAlphaInfo.noneSkipLast.rawValue
      }
    }
    
    let size = size ?? CGSize(width: width, height: height)
    let bounds = CGRect(origin: .zero, size: size)
    
    let context = CGContext(data: nil,
                            width: Int(size.width),
                            height: Int(size.height),
                            bitsPerComponent: bitsPerComponent,
                            bytesPerRow: bytesPerRow,
                            space: colorSpace!,
                            bitmapInfo: bitmapInfo)!
    
    if let info = info {
      switch info {
      case .noneSkipLast(let color):
        context.setFillColor(color)
        context.fill(bounds)
      }
    }
    
    context.draw(self, in: bounds)
    return context.makeImage()!
  }
}

extension CGImage {
  func writeIcon(info: IconInfo, to dir: URL) {
    var path = dir
    path.appendPathComponent("AppIcons")
    path.appendPathComponent(info.idiom.rawValue)
    try? FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
    path.appendPathComponent("\(NSNumber(floatLiteral: Double(info.size))).png")
    
    let size = CGSize(width: info.size, height: info.size)
    if let destination = CGImageDestinationCreateWithURL(path as CFURL, kUTTypePNG as CFString, 1, nil) {
      CGImageDestinationAddImage(destination, compress(.noneSkipLast(color: .white), size: size), nil)
      CGImageDestinationFinalize(destination)
    }
  }
}


let arguments = CommandLine.arguments
let originImagePath = arguments[1]

var dir = URL(fileURLWithPath: originImagePath)
dir.deleteLastPathComponent()

let dataProvider = CGDataProvider(filename: originImagePath)!
let cgImage = CGImage(pngDataProviderSource: dataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)!


let watchOSIcons = [
  IconInfo(idiom: .watch, size: 48),
  IconInfo(idiom: .watch, size: 55),
  IconInfo(idiom: .watch, size: 58),
  IconInfo(idiom: .watch, size: 87),
  IconInfo(idiom: .watch, size: 80),
  IconInfo(idiom: .watch, size: 88),
  IconInfo(idiom: .watch, size: 100),
  IconInfo(idiom: .watch, size: 172),
  IconInfo(idiom: .watch, size: 196),
  IconInfo(idiom: .watch, size: 216),
  IconInfo(idiom: .watch, size: 1024)
]

for icon in watchOSIcons {
  cgImage.writeIcon(info: icon, to: dir)
}

// 参照 https://github.com/abeintopalo/AppIconSetGen
