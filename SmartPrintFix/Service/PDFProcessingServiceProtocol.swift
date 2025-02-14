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

    /// Validates document before processing
    func validateDocument(_ document: PDFDocument) -> Bool
}

// TODO: Future improvements
// - Add document processing check:
//   ```swift
//   /// Checks if document requires processing
//   /// - Parameter document: PDF document to check
//   /// - Returns: true if document needs processing
//   func requiresProcessing(_ document: PDFDocument) -> Bool
//   ```
// - Consider optimization for documents that don't need processing
// - Add progress tracking for large documents


extension PDFProcessingServiceProtocol {
    var minProcessedPagesCount: Int { 1 }
    
    func validateDocument(_ document: PDFDocument) -> Bool {
        guard document.pageCount > 0 else { return false }
        return true
    }
}
