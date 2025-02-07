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
    // инверсия изображения выполняется и результат не nil.
    @Test func testInvertDarkAreas() async throws {
        let pdfPage = PDFPage()
        let contentView = await MainActor.run { ContentView() }
        let result = await contentView.invertDarkAreas(page: pdfPage)

        #expect(result != nil, "The inverted image should not be nil")
    }
    
    //после обработки документ не пуст.
    @Test func testProcessPDF() async throws {
        let document = PDFDocument()
        document.insert(PDFPage(), at: 0)
        
        let contentView = await MainActor.run { ContentView() }
        await contentView.processPDF(document: document)
        
        #expect(document.pageCount > 0, "The processed document should not be empty")
    }
}

