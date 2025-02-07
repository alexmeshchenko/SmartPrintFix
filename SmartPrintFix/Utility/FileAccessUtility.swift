//
//  FileAccessUtility.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 07.02.25.
//


import Foundation

class FileAccessUtility {
    static func checkDownloadsAccess() -> Bool {
        let testFile = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?
            .appendingPathComponent("test_access.txt")
        
        if let testFile = testFile {
            do {
                try "Test".write(to: testFile, atomically: true, encoding: .utf8)
                try FileManager.default.removeItem(at: testFile) // Удаляем тестовый файл
                return true
            } catch {
                return false // Нет доступа
            }
        }
        return false
    }
}
