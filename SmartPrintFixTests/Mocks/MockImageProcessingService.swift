//
//  MockImageProcessingService.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 10.02.25.
//

import PDFKit
import CoreImage
@testable import SmartPrintFix


// Вся логика создания тестовых изображений перенесена в сам мок (логика работы с изображениями скрыта в моке)
// мок полностью отвечает за имитацию сервиса обработки изображений
// Конфигурация изображения теперь делается через свойства мока:
//  * imageSize
//  * bitsPerComponent
// Обработка ошибок теперь происходит внутри мока через shouldReturnNil и проверку размеров

class MockImageProcessingService: ImageProcessingServiceProtocol {
    var shouldReturnNil = false
    var invertDarkAreasCalled = false
    var isAreaDarkCalled = false
    var providedPage: PDFPage?
    
    // Add configuration for image size
    var imageSize: CGSize = CGSize(width: 100, height: 100)
    var bitsPerComponent: Int = 8
    
    func invertDarkAreas(page: PDFPage) async -> CGImage? {
        invertDarkAreasCalled = true
        providedPage = page // Save the transferred page
        
        if shouldReturnNil {
            return nil
        }
        
        // Добавляем вызов isAreaDark
        // Создаем временное CIImage для проверки
        if let context = CGContext(
            data: nil,
            width: Int(imageSize.width),
            height: Int(imageSize.height),
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: Int(imageSize.width) * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ),
           let cgImage = context.makeImage() {
            let ciImage = CIImage(cgImage: cgImage)
            _ = isAreaDark(ciImage)  // Вызываем метод для отметки флага
        }
        
        // Check the correct dimensions
        if imageSize.width <= 0 || imageSize.height <= 0 {
            return nil
        }
        
        return createTestImage()
    }
    
    func isAreaDark(_ image: CIImage) -> Bool {
        isAreaDarkCalled = true
        return true
    }
    
    private func createTestImage() -> CGImage? {
        let context = CGContext(
            data: nil,
            width: Int(imageSize.width),
            height: Int(imageSize.height),
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: Int(imageSize.width) * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        return context?.makeImage()
    }
}
