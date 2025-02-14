//
//  MockPDFProcessingService.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 10.02.25.
//

import PDFKit
import CoreImage
@testable import SmartPrintFix

final class MockPDFProcessingService: PDFProcessingServiceProtocol {
    
    // MARK: - Configuration
    struct Configuration {
        var shouldFailProcessing = false
        var stubbedResult: PDFDocument?
    }
    
    private(set) var configuration: Configuration
    
    // MARK: - Call Tracking
    private(set) var processPDFCalled = false
    private(set) var processPageCalled = false
    private(set) var validateDocumentCalled = false
    private(set) var providedDocument: PDFDocument?
    
    // MARK: - Initialization
    init(configuration: Configuration = .init()) {
        self.configuration = configuration
    }
    
    // MARK: - PDFProcessingServiceProtocol
    func processPDF(document: PDFDocument, state: inout PDFProcessingState) async -> PDFDocument {
        processPDFCalled = true
        providedDocument = document
        
        if configuration.shouldFailProcessing {
            state.addError("Processing failed")
            return PDFDocument()
        }
        
        // Add special processing of empty document
        guard validateDocument(document) else {
            state.addWarning("Processing empty document")
             return PDFDocument()
         }
        
        // Simulate the real service logging
        state.addLog("Processing started...")
        
        var processedPagesCount = 0
         for i in 0..<document.pageCount {
             if let page = document.page(at: i) {
                 if let _ = await processPage(page, pageNumber: i + 1, state: &state) {
                     processedPagesCount += 1
                 }
             }
         }
        
        // Using minProcessedPagesCount from extension
        if processedPagesCount < minProcessedPagesCount {
            state.addError("No pages were processed successfully")
            return PDFDocument()
        }
        
        state.addSuccess("Processing completed")
        return configuration.stubbedResult ?? PDFDocument()
    }
    
    func processPage(_ page: PDFPage, pageNumber: Int, state: inout PDFProcessingState) async -> PDFPage? {
        processPageCalled = true
        state.addLog("Processing page \(pageNumber)...")
        
        if configuration.shouldFailProcessing {
            state.addError("Failed to process page \(pageNumber)")
            return nil
        }
        
        return PDFPage()
    }
    
    func validateDocument(_ document: PDFDocument) -> Bool {
        validateDocumentCalled = true
        return document.pageCount > 0
    }
}

// MARK: - Testing Helpers
extension MockPDFProcessingService {
    func reset() {
        processPDFCalled = false
        processPageCalled = false
        validateDocumentCalled = false
        providedDocument = nil
    }
    
    func configure(_ update: (inout Configuration) -> Void) {
        update(&configuration)
    }
}
