//
//  PDFProcessingState.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 07.02.25.
//


import Foundation
import PDFKit

// Отвечает за данные (Model) и их изменения.

struct PDFProcessingState {
    var pdfDocument: PDFDocument?
    var selectedFileName: String?
    var isProcessing: Bool = false
    var logMessages: [(id: UUID, message: String)] = []
    
    mutating func addLog(_ message: String) {
        logMessages.append((id: UUID(), message: message))
    }
}
