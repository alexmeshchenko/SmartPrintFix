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
    
    // MARK: - Public Methods
    
    func processPDF(document: PDFDocument, state: inout PDFProcessingState) async -> PDFDocument {
        // Проверяем пустой документ
        if document.pageCount == 0 {
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
            
            if let processedCGImage = await imageProcessingService.invertDarkAreas(page: page) {
                let processedImage = NSImage(cgImage: processedCGImage, size: page.bounds(for: .mediaBox).size)
                if let newPage = PDFPage(image: processedImage) {
                    newDocument.insert(newPage, at: i)
                    processedPagesCount += 1
                    state.addLog("Page \(i + 1) processed.")
                } else {
                    state.addLog("Failed to create new page \(i + 1).", type: .error)
                }
            } else {
                state.addLog("Skipping page \(i + 1): processing failed.", type: .warning)
            }
        }
        
        // Проверяем результат обработки
        if processedPagesCount == 0 {
            state.addLog("No pages were processed successfully.", type: .error)
            return PDFDocument()
        } else if processedPagesCount < document.pageCount {
            state.addLog("Processing completed with some errors.", type: .warning)
        } else {
            state.addLog("Processing completed successfully.", type: .success)
        }
        return newDocument
    }
}
