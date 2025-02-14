//
//  ContentView.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 06.02.25.
//

import SwiftUI
import PDFKit

struct ContentView: View {
    
    private enum Constants {
        static let fileType = "public.file-url"
        static let processedFilePrefix = "processed_"
        static let defaultFileName = "document"
    }
    
    @State private var state = PDFProcessingState() // Model (data only)
    @State private var showFilePicker = false
    private let pdfProcessingService: PDFProcessingServiceProtocol // Service (business logic)
    
    // MARK: - View Properties
    private var processedDocument: PDFDocument? {
        guard !state.isProcessing else { return nil }
        return state.processedDocument
    }
    
    // MARK: - Initialization
    init(pdfProcessingService: PDFProcessingServiceProtocol = PDFProcessingService()) {
        self.pdfProcessingService = pdfProcessingService
    }
    
    var body: some View {
        VStack {
            PDFRowView(
                originalDocument: state.pdfDocument,
                processedDocument: processedDocument,
                onDropHandler: handleDrop,
                isProcessing: state.isProcessing, // Transfer state
                onImport: { showFilePicker = true },
                onExport: { exportProcessedPDF() }
            )
            
            // Processing Log (Full Width)
            ProcessingLogView(logMessages: $state.logMessages)
            
        } // VStack
        .padding()
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.pdf],
            onCompletion: handleFileImport
        )
    }
    
}

// MARK: - PDF Processing
private extension ContentView {
    private func processPDF() {
        guard let document = state.pdfDocument else {
            state.addWarning("No PDF document loaded")
            return
        }
        
        Task {
            state.isProcessing = true
            var localState = state // Copy state for async processing
            
            // In Swift 6, the rules for @State, @Published, and @Binding have changed.
            // They are now actor-isolated, which prevents passing them as inout arguments to async functions.
            let newDoc = await pdfProcessingService.processPDF(document: document, state: &localState)
            
            await MainActor.run {
                state = localState
                state.processedDocument = newDoc
                state.isProcessing = false
            }
        }
    }
    
}

// MARK: - File Operations
private extension ContentView {
    func handleFileImport(_ result: Result<URL, Error>) {
        guard FileAccessUtility.checkDownloadsAccess() else {
            state.addWarning("No access to Downloads folder")
            return
        }
        
        switch result {
        case .success(let url):
            loadPDF(from: url)
        case .failure(let error):
            state.addError("File selection failed: \(error.localizedDescription)")
        }
    }
    
    func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else {
            state.addWarning("Invalid file provided")
            return false
        }
        
        provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, error in
            guard let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil) else {
                Task { @MainActor in
                    state.addError("Invalid dropped file")
                }
                return
            }
            
            Task { @MainActor in
                loadPDF(from: url)
            }
        }
        return true
    }
    
}

// MARK: - PDF Processing
private extension ContentView {
    
    func loadPDF(from url: URL) {
        guard !state.isProcessing else {
            state.addWarning("Processing in progress")
            return
        }
        
        guard let document = PDFDocument(url: url) else {
            state.addError("Failed to load PDF")
            return
        }
        
        state.pdfDocument = document
        state.selectedFileName = url.lastPathComponent
        state.addSuccess("Loaded \(url.lastPathComponent)")
        
        // Automatically start processing after boot
        processPDF()
    }
    
    func exportProcessedPDF() {
        guard let document = processedDocument else {
            state.addWarning("No processed document available")
            return
        }
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf]
        savePanel.nameFieldStringValue = "\(Constants.processedFilePrefix)\(state.selectedFileName ?? Constants.defaultFileName).pdf"
        
        savePanel.begin { response in
            guard response == .OK, let url = savePanel.url else {
                state.addWarning("Export cancelled")
                return
            }
            
            document.write(to: url)
            state.addSuccess("Exported to \(url.lastPathComponent)")
        }
    }
}

#Preview {
    ContentView()
}
