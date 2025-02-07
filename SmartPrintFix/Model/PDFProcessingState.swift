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
    var logMessages: [LogEntry] = []

    mutating func addLog(_ message: String) {
        logMessages.append(LogEntry(message: message))
    }
}
