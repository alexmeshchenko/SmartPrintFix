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
    
    mutating func addLog(_ message: String, type: LogEntry.LogType = .info) {
        logMessages.append(LogEntry(message: message, type: type))
    }
    
    // Вспомогательные методы для разных типов логов
    mutating func addError(_ message: String) {
        addLog(message, type: .error)
    }
    
    mutating func addWarning(_ message: String) {
        addLog(message, type: .warning)
    }
    
    mutating func addSuccess(_ message: String) {
        addLog(message, type: .success)
    }
}
