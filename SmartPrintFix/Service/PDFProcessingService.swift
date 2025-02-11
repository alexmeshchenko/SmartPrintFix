//
//  PDFProcessingService.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 07.02.25.
//

import PDFKit
import AppKit

final class PDFProcessingService: PDFProcessingServiceProtocol {
    // MARK: - Dependencies
    private let imageProcessingService: ImageProcessingServiceProtocol
    
    // MARK: - Initialization
    init(imageProcessingService: ImageProcessingServiceProtocol = ImageProcessingService()) {
        self.imageProcessingService = imageProcessingService
    }
    
    // MARK: - PDFProcessingServiceProtocol
    
    func processPDF(document: PDFDocument, state: inout PDFProcessingState) async -> PDFDocument {
        // Проверяем пустой документ
        guard validateDocument(document) else {
            state.addLog("Processing empty document.", type: .warning)
            return PDFDocument()
        }
        
        let newDocument = PDFDocument()
        state.addLog("Processing started...")
        
        var processedPagesCount = 0
        for i in 0..<document.pageCount {
            guard let page = document.page(at: i) else {
                state.addLog("Failed to access page \(i + 1).", type: .error)
                continue
            }
            
            // Проверяем размеры страницы
            let bounds = page.bounds(for: .mediaBox)
            if bounds.width <= 0 || bounds.height <= 0 {
                state.addLog("Invalid page dimensions for page \(i + 1).", type: .error)
                continue
            }
            
            state.addLog("Processing page \(i + 1) of \(document.pageCount)...")
            
            if let processedPage = await processPage(page, pageNumber: i + 1, state: &state) {
                newDocument.insert(processedPage, at: i)
                processedPagesCount += 1
                state.addLog("Page \(i + 1) processed.")
            }
        }
        
        // Проверяем результат обработки
        if processedPagesCount < minProcessedPagesCount {
            state.addLog("No pages were processed successfully.", type: .error)
            return PDFDocument()
        } else if processedPagesCount < document.pageCount {
            state.addLog("Processing completed with some errors.", type: .warning)
        } else {
            state.addLog("Processing completed successfully.", type: .success)
        }
        return newDocument
    }
    
    func processPage(_ page: PDFPage, pageNumber: Int, state: inout PDFProcessingState) async -> PDFPage? {
        guard let processedCGImage = await imageProcessingService.invertDarkAreas(page: page) else {
            state.addLog("Skipping page \(pageNumber): processing failed.", type: .warning)
            return nil
        }
        
        let processedImage = NSImage(cgImage: processedCGImage, size: page.bounds(for: .mediaBox).size)
        guard let newPage = PDFPage(image: processedImage) else {
            state.addLog("Failed to create new page \(pageNumber).", type: .error)
            return nil
        }
        
        return newPage
    }
    
}
