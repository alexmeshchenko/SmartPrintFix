//
//  LogEntry.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 07.02.25.
//

import Foundation

/// A structure representing a single entry in the application's processing log.
///
/// Example:
/// ```swift
/// let log = LogEntry(message: "Processing started")
/// print(log.formattedMessage) // "ℹ️ [14:30:45] Processing started"
/// ```
struct LogEntry: Identifiable {
    /// Unique identifier for the log entry
    let id = UUID()
    
    /// Log message contentt
    let message: String
    
    /// Creation timestamp
    let timestamp: Date = Date()
    
    /// Severity level of the log entry
    let type: LogType
    
    /// Different types of log entries with associated severity levels and icons
    enum LogType {
        case info
        case warning
        case error
        case success
        
        /// Visual representation of the log type
        var icon: String {
            switch self {
            case .info: return "ℹ️"
            case .warning: return "⚠️"
            case .error: return "❌"
            case .success: return "✅"
            }
        }
    }
    
    /// Returns formatted string: "{icon} [HH:mm:ss] {message}"
    var formattedMessage: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return "\(type.icon) [\(formatter.string(from: timestamp))] \(message)"
    }
    
    /// Creates a new log entry
    /// - Parameters:
    ///   - message: Log message content
    ///   - type: Severity level (defaults to .info)
    init(message: String, type: LogType = .info) {
        self.message = message
        self.type = type
    }
}
