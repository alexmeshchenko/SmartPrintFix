//
//  PDFProcessingState.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 07.02.25.
//


import Foundation
import PDFKit

/// Represents the state of PDF processing and logging
struct PDFProcessingState {
    /// Current PDF document being processed
    var pdfDocument: PDFDocument?
    
    var processedDocument: PDFDocument?
    
    /// Name of the selected PDF file
    var selectedFileName: String?
    
    /// Indicates if processing is in progress
    var isProcessing: Bool = false
    
    /// Processing history logs
    var logMessages: [LogEntry] = []
    
    /// Adds a log entry with specified message and type
    mutating func addLog(_ message: String, type: LogEntry.LogType = .info) {
        logMessages.append(LogEntry(message: message, type: type))
    }
    
}

// MARK: - Logging Convenience
extension PDFProcessingState {
    mutating func addError(_ message: String)   { addLog(message, type: .error) }
    mutating func addWarning(_ message: String) { addLog(message, type: .warning) }
    mutating func addSuccess(_ message: String) { addLog(message, type: .success) }
}
