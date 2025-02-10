//
//  SmartPrintFixTests.swift
//  SmartPrintFixTests
//
//  Created by Aleksandr Meshchenko on 06.02.25.
//

import Testing
@testable import SmartPrintFix
import PDFKit

struct SmartPrintFixTests {
    
    // MARK: - Tests
    
    @Test
    func testImageProcessing() async throws {
        // Given
        let mockImageService = MockImageProcessingService()
        let processingService = PDFProcessingService(imageProcessingService: mockImageService)
        
        // When
        let document = PDFDocument()
        document.insert(PDFPage(), at: 0)
        var state = PDFProcessingState()
        
        let processedDocument = await processingService.processPDF(
            document: document,
            state: &state
        )
        
        // Then
        #expect(mockImageService.invertDarkAreasCalled, "Image processing should be called")
        #expect(processedDocument.pageCount > 0, "Processed document should have pages")
        #expect(mockImageService.providedPage != nil, "Service should receive a page to process")
        
        // Дополнительные проверки
        #expect(mockImageService.isAreaDarkCalled, "Dark area detection should be performed")
        #expect(state.logMessages.contains { $0.type == .success }, "Should have success log entry")
        
    }
    
    // тест для случая ошибки:
    @Test
    func testImageProcessingWithError() async throws {
        // Given
        let mockImageService = MockImageProcessingService()
        mockImageService.shouldReturnNil = true // Симулируем ошибку обработки
        let processingService = PDFProcessingService(imageProcessingService: mockImageService)
        
        // When
        let document = PDFDocument()
        document.insert(PDFPage(), at: 0)
        var state = PDFProcessingState()
        
        let processedDocument = await processingService.processPDF(
            document: document,
            state: &state
        )
        
        // Then
        #expect(mockImageService.invertDarkAreasCalled, "Image processing should be called")
        #expect(processedDocument.pageCount == 0, "Failed processing should result in empty document")
        #expect(state.logMessages.contains { $0.type == .error }, "Should have error log entry")
    }
    
    // тест для обработки большого изображения
    @Test
    func testLargeImageProcessing() async throws {
        // Given
        let mockImageService = MockImageProcessingService()
        mockImageService.imageSize = CGSize(width: 1000, height: 1000)
        mockImageService.bitsPerComponent = 8
        
        // When
        let pdfPage = PDFPage()
        let result = await mockImageService.invertDarkAreas(page: pdfPage)
        
        // Then
        #expect(mockImageService.invertDarkAreasCalled, "Large image processing should be called")
        #expect(result != nil, "Should successfully process large image")
        #expect(mockImageService.providedPage === pdfPage, "Should process the correct page")
        
        // Проверяем размеры результата
        if let cgImage = result {
            #expect(cgImage.width == 1000, "Processed image should maintain original width")
            #expect(cgImage.height == 1000, "Processed image should maintain original height")
            #expect(cgImage.bitsPerComponent == 8, "Should maintain bits per component")
        }
    }
    
    // MARK: - Tests
    // инверсия изображения выполняется и результат не nil.
    @Test
    func testInvertDarkAreas() async throws {
        // Given
        let mockImageService = MockImageProcessingService()
        // Настраиваем размер и характеристики тестового изображения напрямую в моке
        mockImageService.imageSize = CGSize(width: 100, height: 100)
        mockImageService.bitsPerComponent = 8
        
        let pdfPage = PDFPage()
        
        // When
        let result = await mockImageService.invertDarkAreas(page: pdfPage)
        
        // Then
        #expect(mockImageService.invertDarkAreasCalled, "invertDarkAreas should be called")
        #expect(result != nil, "The inverted image should not be nil")
        #expect(mockImageService.providedPage === pdfPage, "The service should process the provided page")
        
        // Дополнительные проверки размеров результирующего изображения
        if let cgImage = result {
            #expect(cgImage.width == 100, "Image should maintain configured width")
            #expect(cgImage.height == 100, "Image should maintain configured height")
            #expect(cgImage.bitsPerComponent == 8, "Should maintain configured bits per component")
        }
    }
    
    @Test
    func testInvertDarkAreasWithError() async throws {
        // Given
        let mockImageService = MockImageProcessingService()
        mockImageService.shouldReturnNil = true
        let pdfPage = PDFPage()
        
        // When
        let result = await mockImageService.invertDarkAreas(page: pdfPage)
        
        // Then
        #expect(mockImageService.invertDarkAreasCalled)
        #expect(result == nil, "Should return nil when shouldReturnNil is true")
    }
    
    // случай ошибки при создании изображения
    @Test
    func testInvertDarkAreasWithInvalidImage() async {
        // Given
        let mockImageService = MockImageProcessingService()
        // Устанавливаем некорректные размеры изображения
        mockImageService.imageSize = CGSize(width: -1, height: -1)
        let pdfPage = PDFPage()
        
        // When
        let result = await mockImageService.invertDarkAreas(page: pdfPage)
        
        // Then
        #expect(mockImageService.invertDarkAreasCalled, "Method should be called")
        #expect(result == nil, "Should return nil for invalid image dimensions")
        #expect(mockImageService.providedPage === pdfPage, "Should save provided page even if processing fails")
    }
    
    @Test
    func testInvertDarkAreasWithBlackImage() async throws {
        // Given
        let mockImageService = MockImageProcessingService()
        // Задаем небольшой размер для черного изображения
        mockImageService.imageSize = CGSize(width: 50, height: 50)
        mockImageService.bitsPerComponent = 8
        
        let pdfPage = PDFPage()
        
        // When
        let result = await mockImageService.invertDarkAreas(page: pdfPage)
        
        // Then
        #expect(mockImageService.invertDarkAreasCalled, "invertDarkAreas should be called")
        #expect(mockImageService.isAreaDarkCalled, "isAreaDark should be called")
        #expect(result != nil, "Should return processed image")
        #expect(mockImageService.providedPage === pdfPage, "Should process the provided page")
    }
    
    // тест, проверяющий обработку ошибочного случая:
    @Test
    func testInvertDarkAreasWithFailure() async throws {
        // Given
        let mockImageService = MockImageProcessingService()
        mockImageService.shouldReturnNil = true  // Имитируем ошибку
        let pdfPage = PDFPage()
        
        // When
        let result = await mockImageService.invertDarkAreas(page: pdfPage)
        
        // Then
        #expect(mockImageService.invertDarkAreasCalled, "Method should be called even if it fails")
        #expect(result == nil, "The result should be nil when processing fails")
        #expect(mockImageService.providedPage === pdfPage, "Page should be saved even if processing fails")
        
    }
    
    @Test
    func testProcessPDFWithFailure() async throws {
        // Given
        let mockImageService = MockImageProcessingService()
        mockImageService.shouldReturnNil = true
        let processingService = PDFProcessingService(imageProcessingService: mockImageService)
        
        let document = PDFDocument()
        document.insert(PDFPage(), at: 0)
        var state = PDFProcessingState()
        
        // When
        let processedDocument = await processingService.processPDF(
            document: document,
            state: &state
        )
        
        // Then
        #expect(mockImageService.invertDarkAreasCalled, "Image processing should be attempted")
        #expect(processedDocument.pageCount == 0, "Should return empty document on failure")
        #expect(state.logMessages.contains { $0.type == .error }, "Should log error message")
    }
    
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
    
}

