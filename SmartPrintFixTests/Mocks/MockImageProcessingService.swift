//
//  MockImageProcessingService.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 10.02.25.
//

import PDFKit
import CoreImage
@testable import SmartPrintFix  // Добавляем импорт тестируемого модуля


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
    
    // Добавляем конфигурацию для размера изображения
    var imageSize: CGSize = CGSize(width: 100, height: 100)
    var bitsPerComponent: Int = 8
    
    func invertDarkAreas(page: PDFPage) async -> CGImage? {
        invertDarkAreasCalled = true
        providedPage = page // Сохраняем переданную страницу
        
        if shouldReturnNil {
            return nil
        }
        
        // Проверяем корректность размеров
        if imageSize.width <= 0 || imageSize.height <= 0 {
            return nil
        }
        
        // Возвращаем тестовое изображение
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
