//
//  FileAccessUtility.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 07.02.25.
//


import Foundation

/// Utility for handling file system access operations
class FileAccessUtility {
    /// Checks if the app has write access to Downloads directory
    /// - Returns: True if the app can write to Downloads directory
    static func checkDownloadsAccess() -> Bool {
            guard let downloadsURL = FileManager.default.urls(
                for: .downloadsDirectory,
                in: .userDomainMask
            ).first else { return false }
            
            let testFileURL = downloadsURL.appendingPathComponent(
                "smartprintfix_test_\(UUID().uuidString).tmp"
            )
            
            defer {
                try? FileManager.default.removeItem(at: testFileURL)
            }
            
            do {
                try Data().write(to: testFileURL, options: .atomic)
                return true
            } catch {
                return false
            }
        }
}
