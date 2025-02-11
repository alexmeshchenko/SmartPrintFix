//
//  PDFProcessingServiceProtocol.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 10.02.25.
//

import PDFKit

/// Протокол сервиса обработки PDF документов
protocol PDFProcessingServiceProtocol {
    /// Обрабатывает PDF документ, инвертируя темные области
    /// - Parameters:
    ///   - document: Исходный PDF документ для обработки
    ///   - state: Состояние обработки, включающее логи
    /// - Returns: Обработанный PDF документ
    ///
    /// Гарантии:
    /// - Возвращает пустой документ если:
    ///   - входной документ пуст (pageCount == 0)
    ///   - не удалось обработать ни одну страницу
    /// - Логирует все этапы обработки через state:
    ///   - .info для информационных сообщений
    ///   - .warning для предупреждений (пропуск страниц, пустой документ)
    ///   - .error для ошибок обработки
    ///   - .success при успешном завершении
    /// - Сохраняет порядок страниц
    /// - Потокобезопасен
    func processPDF(document: PDFDocument, state: inout PDFProcessingState) async -> PDFDocument
    
    /// Обрабатывает одну страницу PDF
        /// - Parameters:
        ///   - page: Страница для обработки
        ///   - state: Состояние обработки
        /// - Returns: Обработанная страница или nil в случае ошибки
    func processPage(_ page: PDFPage, pageNumber: Int, state: inout PDFProcessingState) async -> PDFPage?
//
//        /// Проверяет, требует ли документ обработки
//        /// - Parameter document: PDF документ для проверки
//        /// - Returns: true если документ требует обработки
//        func requiresProcessing(_ document: PDFDocument) -> Bool
        
        /// Валидирует документ перед обработкой
        /// - Parameter document: PDF документ для валидации
        /// - Returns: true если документ валиден для обработки
        func validateDocument(_ document: PDFDocument) -> Bool
}

extension PDFProcessingServiceProtocol {
    /// Минимальное количество успешно обработанных страниц для считания документа обработанным
    var minProcessedPagesCount: Int { 1 }
    
    func validateDocument(_ document: PDFDocument) -> Bool {
        guard document.pageCount > 0 else { return false }
        return true
    }
}
