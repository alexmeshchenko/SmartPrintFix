//
//  FileService.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 15.02.25.
//

import Foundation
import PDFKit

final class FileService: FileServiceProtocol {
    private let fileManager = FileManager.default
    
    func checkAccess(to directory: FileDirectory) async -> Bool {
        guard let directoryURL = directory.url else {
            return false
        }
        
        let testFileURL = directoryURL.appendingPathComponent(
            "smartprintfix_test_\(UUID().uuidString).tmp"
        )
        
        defer {
            try? fileManager.removeItem(at: testFileURL)
        }
        
        do {
            try Data().write(to: testFileURL, options: .atomic)
            return true
        } catch {
            return false
        }
    }
    
    func save(_ data: Data, to url: URL) async throws {
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            throw FileError.saveFailed
        }
    }
    
    func read(from url: URL) async throws -> Data {
        do {
            return try Data(contentsOf: url)
        } catch {
            throw FileError.readFailed
        }
    }
    
    func savePDF(_ document: PDFDocument, to url: URL) async throws {
        guard document.write(to: url) else {
            throw FileError.saveFailed
        }
    }
    
    func loadPDF(from url: URL) async throws -> PDFDocument {
        guard let document = PDFDocument(url: url) else {
            throw FileError.invalidPDF
        }
        return document
    }
}
