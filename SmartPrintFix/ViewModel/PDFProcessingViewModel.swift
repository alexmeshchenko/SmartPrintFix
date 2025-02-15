//
//  PDFProcessingViewModel.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 15.02.25.
//

import Foundation
import PDFKit
import SwiftUICore

@MainActor
class PDFProcessingViewModel: ObservableObject, @unchecked Sendable {
    private enum Constants {
        static let processedFilePrefix = "processed_"
        static let defaultFileName = "document"
        static let fileType = "public.file-url"
    }
    
    @Published private(set) var state: PDFProcessingState
    @Published var showFilePicker = false // Add a state for the FilePicker
    
    private let pdfService: PDFProcessingServiceProtocol
    private let fileService: FileServiceProtocol
    
    init(pdfService: PDFProcessingServiceProtocol,
         fileService: FileServiceProtocol) {
        self.pdfService = pdfService
        self.fileService = fileService
        self.state = PDFProcessingState()
    }
    
    // MARK: - Public Methods
    
    func importPDF() {
        showFilePicker = true
    }
    
    func handleFileImport(_ result: Result<URL, Error>) {
        Task {
            guard await fileService.checkAccess(to: .downloads) else {
                updateState { state in
                    state.addWarning("No access to Downloads folder")
                }
                return
            }
            
            switch result {
            case .success(let url):
                await loadPDF(from: url)
            case .failure(let error):
                updateState { state in
                    state.addError("File selection failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first,
              !state.isProcessing else {
            updateState { state in
                state.addWarning("Cannot process now")
            }
            return false
        }
        
        loadPDFFrom(provider)
        return true
    }
    
    func exportPDF() {
        guard let document = state.processedDocument else {
            updateState { state in
                state.addWarning("No processed document available")
            }
            return
        }
        
        // Show the NSSavePanel and save the document
        showSavePanel(for: document)
    }
    
    // MARK: - Private Methods
    
    // MARK: - PDF Processing
    private func processPDF() async {
        guard let document = state.pdfDocument else {
            updateState { state in
                state.addWarning("No PDF document loaded")
            }
            return
        }
        
        updateState { state in
            state.isProcessing = true
        }
        
        var processingState = state
        // In Swift 6, the rules for @State, @Published, and @Binding have changed.
        // They are now actor-isolated, which prevents passing them as inout arguments to async functions.
        let newDoc = await pdfService.processPDF(document: document, state: &processingState)
        
        updateState { state in
            state = processingState
            state.processedDocument = newDoc
            state.isProcessing = false
        }
    }
    
    private func loadPDFFrom(_ provider: NSItemProvider) {
        provider.loadItem(forTypeIdentifier: Constants.fileType, options: nil) { [weak self] item, error in
            guard let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil) else {
                Task { @MainActor in
                    guard let self = self else { return }
                    self.updateState { state in
                        state.addError("Invalid file")
                    }
                }
                return
            }
            
            Task { @MainActor in
                guard let self = self else { return }
                await self.loadPDF(from: url)
            }
        }
    }
    
    private func loadPDF(from url: URL) async {
        guard !state.isProcessing else {
            updateState { state in
                state.addWarning("Processing in progress")
            }
            return
        }
        
        guard let document = PDFDocument(url: url) else {
            updateState { state in
                state.addError("Failed to load PDF")
            }
            return
        }
        
        updateState { state in
            state.pdfDocument = document
            state.selectedFileName = url.lastPathComponent
            state.addSuccess("Loaded \(url.lastPathComponent)")
        }
        
        await processPDF()
    }
    
    private func updateState(_ update: (inout PDFProcessingState) -> Void) {
        var newState = state
        update(&newState)
        state = newState
    }
    
    private func showSavePanel(for document: PDFDocument) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf]
        savePanel.nameFieldStringValue = "\(Constants.processedFilePrefix)\(state.selectedFileName ?? Constants.defaultFileName).pdf"
        
        savePanel.begin { [weak self] response in
            guard let self = self else { return }
            
            guard response == .OK, let url = savePanel.url else {
                self.updateState { state in
                    state.addWarning("Export cancelled")
                }
                return
            }
            
            Task {
                do {
                    try await self.fileService.savePDF(document, to: url)
                    self.updateState { state in
                        state.addSuccess("Exported to \(url.lastPathComponent)")
                    }
                } catch {
                    self.updateState { state in
                        state.addError("Failed to save PDF: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func handleExport(_ action: ExportAction) {
        guard let document = state.processedDocument else {
            updateState { state in
                state.addWarning("No processed document available")
            }
            return
        }
        
        switch action {
        case .save:
            showSavePanel(for: document)
        case .print:
            printDocument(document)
        case .preview:
            previewDocument(document)
        }
    }
    
    private func previewDocument(_ document: PDFDocument) {
        Task {
            let tempFileName = "temp_print_\(UUID().uuidString).pdf"
            let tempDirURL = FileManager.default.temporaryDirectory
            let tempURL = tempDirURL.appendingPathComponent(tempFileName)
            
            // Save the file
            guard document.write(to: tempURL) else {
                updateState { state in
                    state.addError("Failed to save temporary file")
                }
                return
            }
            
            // Verify that the file exists
            guard FileManager.default.fileExists(atPath: tempURL.path) else {
                updateState { state in
                    state.addError("Temporary file was not created")
                }
                return
            }
            
            // Create a configuration for opening
            let configuration = NSWorkspace.OpenConfiguration()
            configuration.activates = true
            configuration.addsToRecentItems = false
            
            // Open in Preview
            NSWorkspace.shared.open(
                [tempURL],
                withApplicationAt: URL(fileURLWithPath: "/System/Applications/Preview.app"),
                configuration: configuration
            ) { [weak self] apps, error in
                // Add a slight delay before deleting the file
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    try? FileManager.default.removeItem(at: tempURL)
                }
                
                if let error = error {
                    self?.updateState { state in
                        state.addError("Failed to print: \(error.localizedDescription)")
                    }
                } else {
                    self?.updateState { state in
                        state.addSuccess("Document opened for printing")
                    }
                }
            }
        }
    }
    
    private func printDocument(_ document: PDFDocument) {
        // Configure print settings
        let printInfo = NSPrintInfo.shared
        printInfo.topMargin = 40
        printInfo.bottomMargin = 40
        printInfo.leftMargin = 40
        printInfo.rightMargin = 40
        
        // Create a PDFView to print all pages
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        
        // Set the size for the entire document
        let pageSize = CGSize(width: 612, height: 792) // A4 size in points
        pdfView.frame = CGRect(
            origin: .zero,
            size: CGSize(
                width: pageSize.width,
                height: pageSize.height * CGFloat(document.pageCount)
            )
        )
        
        // Create a print operation
        let printOperation = NSPrintOperation(view: pdfView, printInfo: printInfo)
        printOperation.showsPrintPanel = true
        printOperation.showsProgressPanel = true
        printOperation.canSpawnSeparateThread = true
        
        // Start printing
        if printOperation.run() {
            updateState { state in
                state.addSuccess("Document sent to printer")
            }
        } else {
            updateState { state in
                state.addWarning("Printing cancelled")
            }
        }
    }
    
    func clearLogs() {
        updateState { state in
            state.logMessages.removeAll()
        }
    }
}
