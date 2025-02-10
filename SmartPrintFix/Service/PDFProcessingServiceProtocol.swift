//
//  PDFProcessingServiceProtocol.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 10.02.25.
//

import PDFKit

protocol PDFProcessingServiceProtocol {
    func processPDF(document: PDFDocument, state: inout PDFProcessingState) async -> PDFDocument
}
