//
//  PDFProcessingServiceProtocol.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 10.02.25.
//

import PDFKit

/// Protocol for PDF processing service
protocol PDFProcessingServiceProtocol {
    /// Processes PDF document and inverts dark areas
    /// - Parameters:
    ///   - document: Source PDF document
    ///   - state: Processing state with logs
    /// - Returns: Processed document or empty if processing failed
    ///
    /// Guarantees:
    /// - Returns empty document if input is empty or processing failed
    /// - Logs all steps via state (.info, .warning, .error, .success)
    /// - Preserves page order
    /// - Thread-safe
    func processPDF(document: PDFDocument, state: inout PDFProcessingState) async -> PDFDocument
    
    /// Processes single PDF page
    /// - Returns: Processed page or nil if failed
    func processPage(_ page: PDFPage, pageNumber: Int, state: inout PDFProcessingState) async -> PDFPage?
    //
    //        /// Проверяет, требует ли документ обработки
    //        /// - Parameter document: PDF документ для проверки
    //        /// - Returns: true если документ требует обработки
    //        func requiresProcessing(_ document: PDFDocument) -> Bool
    
    /// Validates document before processing
    func validateDocument(_ document: PDFDocument) -> Bool
}

extension PDFProcessingServiceProtocol {
    var minProcessedPagesCount: Int { 1 }
    
    func validateDocument(_ document: PDFDocument) -> Bool {
        guard document.pageCount > 0 else { return false }
        return true
    }
}
