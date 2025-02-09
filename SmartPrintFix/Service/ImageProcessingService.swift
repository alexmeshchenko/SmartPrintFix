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

/// Сервис для обработки изображений PDF
/// В рамках MVSU архитектуры реализован как класс сервисного слоя
final class ImageProcessingService {
    
    // MARK: - Properties
    private let context: CIContext
    
    // MARK: - Initialization
    init(context: CIContext = CIContext()) {
        self.context = context
    }
    
    // MARK: - Public Methods
    func invertDarkAreas(page: PDFPage) async -> CGImage? {
        let image = page.thumbnail(of: page.bounds(for: .mediaBox).size, for: .mediaBox)
        
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let cgImage = bitmap.cgImage else { return nil }
        
        // получаем изображение из PDF
        return await detectAndInvertDarkRectangles(cgImage: cgImage)
    }
    
    // MARK: - Private Methods
    
    private func detectAndInvertDarkRectangles(cgImage: CGImage) async -> CGImage? {
        return await withCheckedContinuation { continuation in
            let request = VNDetectRectanglesRequest { [weak self] request, error in
                guard let self = self else {
                    continuation.resume(returning: nil)
                    return
                }
                
                if let error = error {
                    print("Vision error: \(error)")
                    continuation.resume(returning: nil)
                    return
                }
                
                guard let observations = request.results as? [VNRectangleObservation] else {
                    continuation.resume(returning: cgImage)
                    return
                }
                
                var ciImage = CIImage(cgImage: cgImage)
                
                // Фильтруем и обрабатываем только достаточно большие тёмные области
                for observation in observations {
                    let box = observation.boundingBox
                    
                    // Пропускаем слишком маленькие области
                    let minArea = 0.05
                    if (box.width * box.height) < minArea {
                        continue
                    }
                    
                    let imageBox = CGRect(
                        x: box.origin.x * ciImage.extent.width,
                        y: box.origin.y * ciImage.extent.height,
                        width: box.width * ciImage.extent.width,
                        height: box.height * ciImage.extent.height
                    )
                    
                    let croppedImage = ciImage.cropped(to: imageBox)
                    
                    if isAreaDark(croppedImage) {
                        // Создаем маску для этой области
                        guard let whiteColor = CIFilter(name: "CIConstantColorGenerator") else { continue }
                        whiteColor.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: kCIInputColorKey)
                        
                        // Создаем прямоугольную маску
                        let mask = whiteColor.outputImage?.cropped(to: imageBox)
                        
                        // Инвертируем всю область целиком
                        if let invertFilter = CIFilter(name: "CIColorInvert") {
                            invertFilter.setValue(croppedImage, forKey: kCIInputImageKey)
                            
                            if let invertedArea = invertFilter.outputImage {
                                // Создаем смешивающий фильтр
                                guard let blendFilter = CIFilter(name: "CIBlendWithMask") else { continue }
                                
                                // Настраиваем смешивание
                                blendFilter.setValue(ciImage, forKey: kCIInputBackgroundImageKey)
                                blendFilter.setValue(invertedArea, forKey: kCIInputImageKey)
                                blendFilter.setValue(mask, forKey: kCIInputMaskImageKey)
                                
                                if let blendedImage = blendFilter.outputImage {
                                    // Обновляем изображение
                                    ciImage = blendedImage
                                }
                            }
                        }
                    }
                }
                
                if let outputCGImage = self.context.createCGImage(ciImage, from: ciImage.extent) {
                    continuation.resume(returning: outputCGImage)
                } else {
                    continuation.resume(returning: cgImage)
                }
            }
            
            // Настраиваем параметры поиска прямоугольников
            request.minimumAspectRatio = 0.3
            request.maximumAspectRatio = 3.0
            request.minimumSize = 0.1
            request.maximumObservations = 10
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }
    
    private func isAreaDark(_ image: CIImage) -> Bool {
        guard let areaAverage = CIFilter(name: "CIAreaAverage") else {
            return false
        }
        
        areaAverage.setValue(image, forKey: kCIInputImageKey)
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
        
        return brightness < 0.3
    }
}
