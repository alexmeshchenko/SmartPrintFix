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
    //после обработки документ не пуст.
    @Test
    func testProcessPDF() async throws {
        // Given
        let mockPDFService = MockPDFProcessingService()
        let inputDocument = PDFDocument()
        inputDocument.insert(PDFPage(), at: 0)  // Добавляем страницу во входной документ
        
        let resultDocument = PDFDocument()
        let processedPage = PDFPage()
        resultDocument.insert(processedPage, at: 0)
        mockPDFService.stubbedResult = resultDocument  // Устанавливаем ожидаемый результат
        
        var state = PDFProcessingState()
        
        // When
        let processedDocument = await mockPDFService.processPDF(
            document: inputDocument,
            state: &state
        )
        
        // Then
        #expect(mockPDFService.processPDFCalled, "PDF processing should be called")
        #expect(processedDocument.pageCount > 0, "Processed document should not be empty")
        #expect(mockPDFService.providedDocument === inputDocument, "Service should process the provided document") // проверки идентичности объектов
        
        // Проверяем лог обработки
        #expect(state.logMessages.contains { $0.type == .success }, "Should have success log entry") // Проверяем конкретные типы логов
    }
    
    // для проверки обработки пустого документа:
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
        #expect(mockPDFService.processPDFCalled, "Processing should be called even for empty document") // Проверка обработки пустого документа
        #expect(processedDocument.pageCount == 0, "Processed empty document should remain empty")
        #expect(state.logMessages.contains { $0.type == .warning }, "Should have warning log for empty document") // Проверка корректности логирования предупреждений
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
    
}
