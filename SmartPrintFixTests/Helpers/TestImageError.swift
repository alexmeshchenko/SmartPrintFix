////
////  TestImageError.swift
////  SmartPrintFix
////
////  Created by Aleksandr Meshchenko on 10.02.25.
////
//
//
//import CoreGraphics
//
//enum TestImageError: Error {
//    case contextCreationFailed
//    case imageGenerationFailed
//}
//
//struct TestImageConfig {
//    let width: Int
//    let height: Int
//    let color: CGColor
//    let bitsPerComponent: Int
//    let bytesPerRow: Int?
//    
//    static let `default` = TestImageConfig(
//        width: 100,
//        height: 100,
//        color: CGColor(red: 1, green: 1, blue: 1, alpha: 1),
//        bitsPerComponent: 8,
//        bytesPerRow: nil
//    )
//}
//
//func createTestCGImage(
//    config: TestImageConfig = .default
//) throws -> CGImage {
//    let bytesPerRow = config.bytesPerRow ?? config.width * 4
//    
//    guard let context = CGContext(
//        data: nil,
//        width: config.width,
//        height: config.height,
//        bitsPerComponent: config.bitsPerComponent,
//        bytesPerRow: bytesPerRow,
//        space: CGColorSpaceCreateDeviceRGB(),
//        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
//    ) else {
//        throw TestImageError.contextCreationFailed
//    }
//    
//    context.setFillColor(config.color)
//    context.fill(CGRect(x: 0, y: 0, width: config.width, height: config.height))
//    
//    guard let image = context.makeImage() else {
//        throw TestImageError.imageGenerationFailed
//    }
//    
//    return image
//}
