//
//  PDFKitView.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 06.02.25.
//

import SwiftUI
import PDFKit

struct PDFKitView: NSViewRepresentable {
    let document: PDFDocument
    
    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateNSView(_ nsView: PDFView, context: Context) {}
}
