//
//  PDFProcessingService.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 07.02.25.
//


import PDFKit
import AppKit

class PDFProcessingService {
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
    
    static func processPDF(document: PDFDocument, log: inout [String]) async -> PDFDocument {
        let newDocument = PDFDocument()
        
        for i in 0..<document.pageCount {
            if let page = document.page(at: i) {
                log.append("Processing page \(i + 1) of \(document.pageCount)...")
                
                if let processedCGImage = await invertDarkAreas(page: page) {
                    let processedImage = NSImage(cgImage: processedCGImage, size: page.bounds(for: .mediaBox).size)
                    
                    if let newPage = PDFPage(image: processedImage) {
                        newDocument.insert(newPage, at: i)
                        log.append("Page \(i + 1) processed.")
                    } else {
                        log.append("Failed to create new page for page \(i + 1).")
                    }
                } else {
                    log.append("Skipping page \(i + 1): processing failed.")
                }
            }
        }
        return newDocument
    }
}
