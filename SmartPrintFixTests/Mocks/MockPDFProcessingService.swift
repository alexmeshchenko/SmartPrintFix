//
//  MockPDFProcessingService.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 10.02.25.
//

import PDFKit
import CoreImage
@testable import SmartPrintFix  // Добавляем импорт тестируемого модуля

final class MockPDFProcessingService: PDFProcessingServiceProtocol {
    // MARK: - Test Properties
    
    var processPDFCalled = false
    var processPageCalled = false
    var validateDocumentCalled = false
    
    var providedDocument: PDFDocument?
    var stubbedResult: PDFDocument?
    var shouldFailProcessing = false
    
    // MARK: - PDFProcessingServiceProtocol
    
    func processPDF(document: PDFDocument, state: inout PDFProcessingState) async -> PDFDocument {
        processPDFCalled = true
        providedDocument = document
        
        // Добавляем специальную обработку пустого документа
        guard validateDocument(document) else {
             state.addLog("Processing empty document.", type: .warning)
             return PDFDocument()
         }
        
        if shouldFailProcessing {
            state.addLog("Processing failed.", type: .error)
            return PDFDocument()
        }
        
        // Имитируем логирование реального сервиса
        state.addLog("Processing started...")
        
        var processedPagesCount = 0
         for i in 0..<document.pageCount {
             if let page = document.page(at: i) {
                 if let _ = await processPage(page, pageNumber: i + 1, state: &state) {
                     processedPagesCount += 1
                 }
             }
         }
        
        // Используем minProcessedPagesCount из extension
        if processedPagesCount < minProcessedPagesCount {
            state.addLog("No pages were processed successfully.", type: .error)
            return PDFDocument()
        }
        
        state.addLog("Processing completed.", type: .success)
        return stubbedResult ?? PDFDocument()
    }
    
    func processPage(_ page: PDFPage, pageNumber: Int, state: inout PDFProcessingState) async -> PDFPage? {
        processPageCalled = true
        state.addLog("Processing page \(pageNumber)...")
        
        if shouldFailProcessing {
            state.addLog("Failed to process page \(pageNumber).", type: .error)
            return nil
        }
        
        return PDFPage()
    }
    
    func validateDocument(_ document: PDFDocument) -> Bool {
        validateDocumentCalled = true
        if shouldFailProcessing {
            return false
        }
        guard document.pageCount > 0 else { return false }
        return true
    }
}
