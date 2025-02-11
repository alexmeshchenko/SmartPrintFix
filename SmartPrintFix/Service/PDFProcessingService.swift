//
//  PDFProcessingService.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 07.02.25.
//

import PDFKit
import AppKit

/// Service for processing PDF documents
final class PDFProcessingService: PDFProcessingServiceProtocol {
    private let imageProcessingService: ImageProcessingServiceProtocol
    
    // MARK: - Initialization
    init(imageProcessingService: ImageProcessingServiceProtocol = ImageProcessingService()) {
        self.imageProcessingService = imageProcessingService
    }
    
    // MARK: - PDFProcessingServiceProtocol
    func processPDF(document: PDFDocument, state: inout PDFProcessingState) async -> PDFDocument {
        // Checking empty document
        guard validateDocument(document) else {
            state.addLog("Processing empty document.", type: .warning)
            return PDFDocument()
        }
        
        let newDocument = PDFDocument()
        state.addLog("Processing started...")
        
        let processedPages = await withTaskGroup(of: (Int, PDFPage?).self) { group -> [(Int, PDFPage?)] in
            let statePointer = UnsafeMutablePointer<PDFProcessingState>.allocate(capacity: 1)
            statePointer.initialize(to: state)
            defer {
                state = statePointer.pointee
                statePointer.deallocate()
            }
            
            for pageIndex in 0..<document.pageCount {
                group.addTask {
                    guard let page = document.page(at: pageIndex) else { return (pageIndex, nil) }
                    return (pageIndex, await self.processPage(page,
                                                            pageNumber: pageIndex + 1,
                                                            state: &statePointer.pointee))
                }
            }
            
            return await group.reduce(into: [(Int, PDFPage?)]()) { result, page in
                result.append(page)
            }.sorted(by: { $0.0 < $1.0 })
        }
        
        processedPages.forEach { if let page = $1 { newDocument.insert(page, at: $0) } }
        
        let successCount = processedPages.compactMap(\.1).count
        if successCount < minProcessedPagesCount {
            state.addError("No pages were processed successfully")
            return PDFDocument()
        }
        
        state.addSuccess("Processing completed successfully")
        return newDocument
    }
    
    // создание PDFPage происходит в фоновом потоке, но мы ожидаем результат в потоке с более высоким приоритетом.
    func processPage(_ page: PDFPage, pageNumber: Int, state: inout PDFProcessingState) async -> PDFPage? {
        guard let processedCGImage = await imageProcessingService.invertDarkAreas(page: page) else {
            state.addWarning("Failed to process page \(pageNumber)")
            return nil
        }
        
        return await Task.detached {
            let processedImage = NSImage(cgImage: processedCGImage,
                                       size: page.bounds(for: .mediaBox).size)
            guard let pdfPage = PDFPage(image: processedImage) else { return nil }
            return pdfPage
        }.value
    }
    
}
