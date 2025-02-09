//
//  PDFProcessingService.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 07.02.25.
//

import PDFKit
import AppKit

final class PDFProcessingService {
    // MARK: - Dependencies
    
    private let imageProcessingService: ImageProcessingService
    
    // MARK: - Initialization
    
    init(imageProcessingService: ImageProcessingService = ImageProcessingService()) {
        self.imageProcessingService = imageProcessingService
    }
    
    // MARK: - Public Methods
    
    func processPDF(document: PDFDocument, state: inout PDFProcessingState) async -> PDFDocument {
        let newDocument = PDFDocument()
        state.addLog("Processing started...")

        for i in 0..<document.pageCount {
            if let page = document.page(at: i) {
                state.addLog("Processing page \(i + 1) of \(document.pageCount)...")

                if let processedCGImage = await imageProcessingService.invertDarkAreas(page: page) {
                    let processedImage = NSImage(cgImage: processedCGImage, size: page.bounds(for: .mediaBox).size)
                    if let newPage = PDFPage(image: processedImage) {
                        newDocument.insert(newPage, at: i)
                        state.addLog("Page \(i + 1) processed.")
                    } else {
                        state.addLog("Failed to create new page \(i + 1).", type: .error)
                    }
                } else {
                    state.addLog("Skipping page \(i + 1): processing failed.", type: .warning)
                }
            }
        }

        state.addLog("Processing completed.", type: .success)
        return newDocument
    }
}
