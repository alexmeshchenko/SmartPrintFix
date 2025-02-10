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
    var processPDFCalled = false
    var providedDocument: PDFDocument?
    var stubbedResult: PDFDocument?
    
    func processPDF(document: PDFDocument, state: inout PDFProcessingState) async -> PDFDocument {
        processPDFCalled = true
        providedDocument = document
        
        // Добавляем специальную обработку пустого документа
        if document.pageCount == 0 {
            state.addLog("Processing empty document.", type: .warning)
            return PDFDocument() // Возвращаем пустой документ
        }
        
        // Имитируем логирование реального сервиса
        state.addLog("Processing started...")
        state.addLog("Processing completed.", type: .success)
        
        return stubbedResult ?? PDFDocument()
    }
}
