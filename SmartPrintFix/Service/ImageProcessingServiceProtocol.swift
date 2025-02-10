//
//  ImageProcessingServiceProtocol.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 10.02.25.
//

import CoreGraphics
import CoreImage
import PDFKit

protocol ImageProcessingServiceProtocol {
    /// Инвертирует темные области на странице PDF
    /// - Parameter page: Страница PDF для обработки
    /// - Returns: Обработанное изображение в формате CGImage, или nil в случае ошибки
    func invertDarkAreas(page: PDFPage) async -> CGImage?
    
    /// Определяет, является ли область изображения темной
    /// - Parameter image: Изображение для анализа
    /// - Returns: true если область считается темной
    func isAreaDark(_ image: CIImage) -> Bool
}
