//
//  FileServiceProtocol.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 15.02.25.
//

import PDFKit

protocol FileServiceProtocol {
    func hasAccessToDownloads() async -> Bool
    func savePDF(_ document: PDFDocument, to url: URL) async throws
    func loadPDF(from url: URL) async throws -> PDFDocument
}
