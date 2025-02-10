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
/// Сохраняем консистентность поведения с моком
final class ImageProcessingService: ImageProcessingServiceProtocol {
    
    // MARK: - Properties
    private let context: CIContext
    
    // MARK: - Initialization
    init(context: CIContext = CIContext()) {
        self.context = context
    }
    
    // MARK: - ImageProcessingServiceProtocol
    func invertDarkAreas(page: PDFPage) async -> CGImage? {
        
        // Проверяем входные данные
        let bounds = page.bounds(for: .mediaBox)
        if bounds.width <= 0 || bounds.height <= 0 {
            NSLog("Invalid page dimensions: width = \(bounds.width), height = \(bounds.height)")
            return nil
        }
        
        // Получаем изображение в максимальном качестве
        let image = page.thumbnail(of: CGSize(
            width: page.bounds(for: .mediaBox).width * 2,  // Увеличиваем разрешение
            height: page.bounds(for: .mediaBox).height * 2
        ), for: .mediaBox)
        
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let cgImage = bitmap.cgImage else {
            NSLog("Failed to create image from PDF page")
            return nil // Явно возвращаем nil при ошибке
        }
        NSLog("Successfully created image from PDF page")
        return await detectAndInvertDarkRectangles(cgImage: cgImage)
    }
    
    func isAreaDark(_ image: CIImage) -> Bool {
        guard let colorControls = CIFilter(name: "CIColorControls") else {
            return false
        }
        
        // Увеличим контраст для лучшего отделения темных областей
        colorControls.setValue(image, forKey: kCIInputImageKey)
        colorControls.setValue(1.5, forKey: "inputContrast")
        colorControls.setValue(0.0, forKey: "inputSaturation")  // Уберем цвет
        
        guard let contrastImage = colorControls.outputImage,
              let areaAverage = CIFilter(name: "CIAreaAverage") else {
            return false
        }
        
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
        
        return brightness < 0.4  // Немного увеличим порог
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
                    
                    if self.isAreaDark(croppedImage) {
                                            if let invertedArea = self.invertArea(croppedImage),
                                               let blendedImage = self.blendArea(original: ciImage,
                                                                               inverted: invertedArea,
                                                                               in: imageBox) {
                                                ciImage = blendedImage
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
    
    // MARK: - Helper Methods
        
        private func invertArea(_ image: CIImage) -> CIImage? {
            guard let invertFilter = CIFilter(name: "CIColorInvert") else { return nil }
            invertFilter.setValue(image, forKey: kCIInputImageKey)
            return invertFilter.outputImage
        }
        
        private func blendArea(original: CIImage, inverted: CIImage, in rect: CGRect) -> CIImage? {
            guard let whiteColor = CIFilter(name: "CIConstantColorGenerator") else { return nil }
            whiteColor.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: kCIInputColorKey)
            
            guard let mask = whiteColor.outputImage?.cropped(to: rect),
                  let blendFilter = CIFilter(name: "CIBlendWithMask") else { return nil }
            
            blendFilter.setValue(original, forKey: kCIInputBackgroundImageKey)
            blendFilter.setValue(inverted, forKey: kCIInputImageKey)
            blendFilter.setValue(mask, forKey: kCIInputMaskImageKey)
            
            return blendFilter.outputImage
        }
    
}
