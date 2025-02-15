//
//  FileService.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 15.02.25.
//

import PDFKit

class FileService: FileServiceProtocol {
    func hasAccessToDownloads() async -> Bool {
        FileAccessUtility.checkDownloadsAccess()
    }
    
    func savePDF(_ document: PDFDocument, to url: URL) async throws {
        document.write(to: url)
    }
    
    func loadPDF(from url: URL) async throws -> PDFDocument {
        guard let document = PDFDocument(url: url) else {
            throw FileError.invalidPDF
        }
        return document
    }
}

enum FileError: Error {
    case invalidPDF
    case accessDenied
    case saveFailed
}
