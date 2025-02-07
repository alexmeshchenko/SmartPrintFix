//
//  ImageProcessingService.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 07.02.25.
//

import CoreGraphics
import PDFKit

struct ImageProcessingService {
    // Логика инвертирования тёмных областей
    static func invertDarkAreas(page: PDFPage) async -> CGImage? {
        let image = page.thumbnail(of: page.bounds(for: .mediaBox).size, for: .mediaBox)
        
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let cgImage = bitmap.cgImage else { return nil }
        
        return await processImage(cgImage: cgImage)
    }
    
    static func processImage(cgImage: CGImage) async -> CGImage? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let context = CIContext()
                let ciImage = CIImage(cgImage: cgImage)
                let invertFilter = CIFilter(name: "CIColorInvert")
                invertFilter?.setValue(ciImage, forKey: kCIInputImageKey)
                
                if let outputImage = invertFilter?.outputImage,
                   let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) {
                    continuation.resume(returning: outputCGImage)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
