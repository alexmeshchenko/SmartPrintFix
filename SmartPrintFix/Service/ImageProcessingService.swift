//
//  ImageProcessingService.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 07.02.25.
//

import Vision
import CoreGraphics
import PDFKit
import AppKit

actor CIContextService {
    private let context: CIContext
    
    init(context: CIContext = CIContext()) {
        self.context = context
    }
    
    func createCGImage(from image: CIImage, in extent: CGRect) -> CGImage? {
        context.createCGImage(image, from: extent)
    }
}

/// Service for processing PDF images with dark area detection and inversion
final class ImageProcessingService: ImageProcessingServiceProtocol {
    private let context: CIContext
    private static let minAreaSize = 0.05
    
    init(context: CIContext = CIContext()) {
        self.context = context
    }
    
    // MARK: - ImageProcessingServiceProtocol
    func invertDarkAreas(page: PDFPage) async -> CGImage? {
        let bounds = page.bounds(for: .mediaBox)
        guard bounds.width > 0, bounds.height > 0,
              let cgImage = pdfPageToCGImage(page) else { return nil }
        return await detectAndInvertDarkRectangles(cgImage: cgImage)
    }
    
    func isAreaDark(_ image: CIImage) async -> Bool {
        // Prepare filters
        guard let colorControls = CIFilter(name: "CIColorControls"),
              let areaAverage = CIFilter(name: "CIAreaAverage") else { return false }
        
        colorControls.setValue(image, forKey: kCIInputImageKey)
        colorControls.setValue(1.5, forKey: "inputContrast")
        colorControls.setValue(0.0, forKey: "inputSaturation")
        
        guard let contrastImage = colorControls.outputImage else { return false }
        
        areaAverage.setValue(contrastImage, forKey: kCIInputImageKey)
        areaAverage.setValue(CIVector(cgRect: image.extent), forKey: "inputExtent")
        
        guard let outputImage = areaAverage.outputImage,
              let averageColor = context.createCGImage(outputImage, from: outputImage.extent),
              let dataProvider = averageColor.dataProvider,
              let data = dataProvider.data,
              let bytes = CFDataGetBytePtr(data) else {
            return false
        }
        
        let brightness = (0.299 * Double(bytes[0]) +
                          0.587 * Double(bytes[1]) +
                          0.114 * Double(bytes[2])) / 255.0
        
        return brightness < Self.darknessTreshold
    }
    
}

// MARK: - Private Methods
private extension ImageProcessingService {
    func pdfPageToCGImage(_ page: PDFPage) -> CGImage? {
        // Check the input
        let bounds = page.bounds(for: .mediaBox)
        // Get maximum quality image
        let size = CGSize(width: bounds.width * 2, height: bounds.height * 2)
        let image = page.thumbnail(of: size, for: .mediaBox)
        
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else { return nil }
        
        return bitmap.cgImage
    }
    
    // MARK: - Private Methods
    func detectAndInvertDarkRectangles(cgImage: CGImage) async -> CGImage? {
        await withCheckedContinuation { continuation in
            Task(priority: .userInitiated) {
                let request = VNDetectRectanglesRequest { [weak self] request, error in
                    guard let self = self,
                          error == nil,
                          let observations = request.results as? [VNRectangleObservation] else {
                        return continuation.resume(returning: cgImage)
                    }
                    
                    Task {
                        let processedImage = await self.processObservations(observations, cgImage: cgImage)
                        continuation.resume(returning: processedImage ?? cgImage)
                    }
                }
                
                configureRectangleRequest(request)
                
                do {
                    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                    try handler.perform([request])
                } catch {
                    continuation.resume(returning: cgImage)
                }
            }
        }
    }
    
    func processObservations(_ observations: [VNRectangleObservation], cgImage: CGImage) async -> CGImage? {
        var ciImage = CIImage(cgImage: cgImage)
        
        for observation in observations where observation.boundingBox.area > Self.minAreaSize {
            let imageBox = observation.boundingBox.scaled(to: ciImage.extent)
            let croppedImage = ciImage.cropped(to: imageBox)
            
            if await isAreaDark(croppedImage),
               let invertedArea = invertArea(croppedImage),
               let blended = blendArea(original: ciImage, inverted: invertedArea, in: imageBox) {
                ciImage = blended
            }
        }
        
        return context.createCGImage(ciImage, from: ciImage.extent)
    }
    
    private func invertArea(_ image: CIImage) -> CIImage? {
        guard let invertFilter = CIFilter(name: "CIColorInvert") else { return nil }
        invertFilter.setValue(image, forKey: kCIInputImageKey)
        return invertFilter.outputImage
    }
    
    private func blendArea(original: CIImage, inverted: CIImage, in rect: CGRect) -> CIImage? {
        guard let whiteColor = CIFilter(name: "CIConstantColorGenerator"),
              let blendFilter = CIFilter(name: "CIBlendWithMask") else { return nil }
        
        whiteColor.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: kCIInputColorKey)
        
        guard let mask = whiteColor.outputImage?.cropped(to: rect) else { return nil }
        
        blendFilter.setValue(original, forKey: kCIInputBackgroundImageKey)
        blendFilter.setValue(inverted, forKey: kCIInputImageKey)
        blendFilter.setValue(mask, forKey: kCIInputMaskImageKey)
        
        return blendFilter.outputImage
    }
    
    func configureRectangleRequest(_ request: VNDetectRectanglesRequest) {
        request.minimumAspectRatio = 0.3
        request.maximumAspectRatio = 3.0
        request.minimumSize = 0.1
        request.maximumObservations = 10
    }
    
}

// MARK: - Helpers
private extension CGRect {
    var area: CGFloat { width * height }
    
    func scaled(to rect: CGRect) -> CGRect {
        CGRect(
            x: origin.x * rect.width,
            y: origin.y * rect.height,
            width: width * rect.width,
            height: height * rect.height
        )
    }
}
