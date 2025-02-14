//
//  PDFProcessingTests.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 11.02.25.
//


import Testing
@testable import SmartPrintFix
import PDFKit

struct PDFProcessingTests {
    
    //Check if the document is not empty after processing.
    @Test
    func testProcessPDF() async throws {
        // Given
        let mockPDFService = MockPDFProcessingService()
        let inputDocument = PDFDocument()
        inputDocument.insert(PDFPage(), at: 0)  // Add page to input document
        
        let resultDocument = PDFDocument()
        let processedPage = PDFPage()
        resultDocument.insert(processedPage, at: 0)
        mockPDFService.configure { config in
            config.stubbedResult = resultDocument // Set expected result
        }
        
        var state = PDFProcessingState()
        
        // When
        let processedDocument = await mockPDFService.processPDF(
            document: inputDocument,
            state: &state
        )
        
        // Then
        #expect(mockPDFService.processPDFCalled, "PDF processing should be called")
        #expect(processedDocument.pageCount > 0, "Processed document should not be empty")
        #expect(mockPDFService.providedDocument === inputDocument, "Service should process the provided document") // object identity checks
        
        // Check the log
        #expect(state.logMessages.contains { $0.type == .success }, "Should have success log entry") // Check specific types of logs
    }
    
    // to check the processing of a blank document:
    @Test
    func testProcessEmptyPDF() async throws {
        // Given
        let mockPDFService = MockPDFProcessingService()
        let emptyDocument = PDFDocument()
        var state = PDFProcessingState()
        
        // When
        let processedDocument = await mockPDFService.processPDF(
            document: emptyDocument,
            state: &state
        )
        
        // Then
        #expect(mockPDFService.processPDFCalled, "Processing should be called even for empty document") // Checking the empty document processing
        #expect(processedDocument.pageCount == 0, "Processed empty document should remain empty")
        #expect(state.logMessages.contains { $0.type == .warning }, "Should have warning log for empty document") // Checking the correctness of the warning logic
    }
    
    @Test
    func testProcessSinglePage() async throws {
        // Given
        let mockPDFService = MockPDFProcessingService()
        let page = PDFPage()
        var state = PDFProcessingState()
        
        // When
        let processedPage = await mockPDFService.processPage(page, pageNumber: 1, state: &state)
        
        // Then
        #expect(mockPDFService.processPageCalled, "Page processing should be called")
        #expect(processedPage != nil, "Should return processed page")
        #expect(state.logMessages.contains { $0.message.contains("Processing page 1") },
                "Should log page processing")
    }
    
    @Test
    func testProcessPDFWithFailure() async throws {
        // Given
        let mockPDFService = MockPDFProcessingService()
        mockPDFService.configure { config in
            config.shouldFailProcessing = true
        }
        
        let inputDocument = PDFDocument()
        inputDocument.insert(PDFPage(), at: 0)
        var state = PDFProcessingState()
        
        // When
        let processedDocument = await mockPDFService.processPDF(
            document: inputDocument,
            state: &state
        )
        
        // Then
        #expect(mockPDFService.processPDFCalled, "Processing should be called")
        #expect(processedDocument.pageCount == 0, "Failed processing should result in empty document")
        #expect(mockPDFService.providedDocument === inputDocument, "Service should store provided document")
        #expect(state.logMessages.contains { $0.type == .error }, "Should have error log entry")
    }
    
}
