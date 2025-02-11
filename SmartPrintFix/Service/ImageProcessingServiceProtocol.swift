//
//  ImageProcessingServiceProtocol.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 10.02.25.
//

import CoreGraphics
import CoreImage
import PDFKit

/// Протокол сервиса обработки изображений
protocol ImageProcessingServiceProtocol {
    /// Инвертирует темные области на странице PDF
    /// - Parameter page: Страница PDF для обработки
    /// - Returns: Обработанное изображение в формате CGImage, или nil в случае ошибки
    ///
    /// Гарантии:
    /// - Возвращает nil если:
    ///   - страница имеет некорректные размеры (ширина или высота <= 0)
    ///   - не удалось создать изображение из страницы
    ///   - произошла ошибка при обработке изображения
    /// - Сохраняет оригинальные размеры и характеристики изображения
    /// - Потокобезопасен
    func invertDarkAreas(page: PDFPage) async -> CGImage?
    
    /// Определяет, является ли область изображения темной
    /// - Parameter image: Изображение для анализа
    /// - Returns: true если область считается темной
    ///
    /// Реализации должны:
    /// - Использовать согласованный алгоритм определения темных областей
    /// - Корректно обрабатывать различные цветовые пространства
    /// - Учитывать общую яркость изображения
    func isAreaDark(_ image: CIImage) -> Bool
}

extension ImageProcessingServiceProtocol {
    /// Рекомендуемый порог яркости для определения темной области
    static var darknessTreshold: Double { 0.4 }
}
