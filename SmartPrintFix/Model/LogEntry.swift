//
//  LogEntry.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 07.02.25.
//

import Foundation

/// Represents a single log entry in the application's processing log
/// Used to track operations and their status during PDF processing
struct LogEntry: Identifiable {
    /// Unique identifier for the log entry
    let id = UUID()
    
    /// The log message content
    let message: String
    
    /// Timestamp when the log entry was created
    let timestamp: Date = Date()
    
    /// The type/severity of the log entry
    let type: LogType
    
    /// Represents different types of log entries
    enum LogType {
        case info
        case warning
        case error
        case success
        
        var icon: String {
            switch self {
            case .info: return "ℹ️"
            case .warning: return "⚠️"
            case .error: return "❌"
            case .success: return "✅"
            }
        }
    }
    
    /// Creates a formatted string representation of the log entry
    var formattedMessage: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return "\(type.icon) [\(formatter.string(from: timestamp))] \(message)"
    }
    
    /// Конструктор по умолчанию использует тип .info
        init(message: String, type: LogType = .info) {
            self.message = message
            self.type = type
        }
}
