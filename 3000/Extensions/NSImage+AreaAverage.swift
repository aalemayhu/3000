// https://stackoverflow.com/questions/26330924/get-average-color-of-uiimage-in-swift

import Cocoa
import CoreImage

extension NSImage {
    func areaAverage() -> NSColor {
        var bitmap = [UInt8](repeating: 0, count: 4)
        
        // Get average color.
        let context = CIContext()
        guard let cgImage = self.CGImage else { return NSColor.white }
        let inputImage = CIImage(cgImage: cgImage) 
        let extent = inputImage.extent
        let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: inputExtent]), let outputImage = filter.outputImage else { return NSColor.white }
        let outputExtent = outputImage.extent
        assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)
        
        // Render to bitmap.
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: CIFormat.RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        
        // Compute result.
        let result = NSColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
        return result
    }
    
    // https://stackoverflow.com/questions/24595908/swift-nsimage-to-cgimage/24595958#24595958
    var CGImage: CGImage? {
        get {
            guard let imageData = self.tiffRepresentation else { return nil}
            let cfdata = imageData as CFData
            guard let source = CGImageSourceCreateWithData(cfdata, nil) else { return nil}
            return CGImageSourceCreateImageAtIndex(source, 0, nil)
        }
    }
}
