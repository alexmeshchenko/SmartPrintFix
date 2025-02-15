//
//  FileError.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 15.02.25.
//


// FileError.swift
import Foundation

enum FileError: LocalizedError {
    case accessDenied
    case invalidPDF
    case saveFailed
    case readFailed
    case invalidDirectory
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Access to directory denied"
        case .invalidPDF:
            return "Invalid PDF document"
        case .saveFailed:
            return "Failed to save file"
        case .readFailed:
            return "Failed to read file"
        case .invalidDirectory:
            return "Invalid directory path"
        }
    }
}