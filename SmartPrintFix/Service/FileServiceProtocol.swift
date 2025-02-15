//
//  FileServiceProtocol.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 15.02.25.
//

import Foundation
import PDFKit

protocol FileServiceProtocol {
    /// Checks if the app has access to specified directory
    func checkAccess(to directory: FileDirectory) async -> Bool
    
    /// Saves data to specified URL
    func save(_ data: Data, to url: URL) async throws
    
    /// Reads data from specified URL
    func read(from url: URL) async throws -> Data
    
    /// Specific method for saving PDF documents
    func savePDF(_ document: PDFDocument, to url: URL) async throws
    
    /// Specific method for reading PDF documents
    func loadPDF(from url: URL) async throws -> PDFDocument
}
