//
//  PDFProcessingViewModel.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 15.02.25.
//

import Foundation
import PDFKit

@MainActor
class PDFProcessingViewModel: ObservableObject, @unchecked Sendable {
    private enum Constants {
        static let processedFilePrefix = "processed_"
        static let defaultFileName = "document"
        static let fileType = "public.file-url"
    }
    
    @Published private(set) var state: PDFProcessingState
    @Published var showFilePicker = false // Добавляем состояние для FilePicker
    
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
            guard await fileService.hasAccessToDownloads() else {
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
        
        // Показываем NSSavePanel и сохраняем документ
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
}
