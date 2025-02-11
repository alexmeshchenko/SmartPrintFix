//
//  ContentView.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 06.02.25.
//

import SwiftUI
import PDFKit

struct ContentView: View {
    @State private var state = PDFProcessingState()
    @State private var showFilePicker = false
    
    private let pdfProcessingService: PDFProcessingServiceProtocol
    
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
    
    private var processedDocument: PDFDocument? {
        guard !state.isProcessing else { return nil }
        return state.processedDocument
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
            
            // 1. Копируем состояние
            var localState = state
            
            // 2. Запускаем обработку через инстанс сервиса
            // В Swift 6 изменились правила работы с @State, @Published и @Binding.
            // Они теперь actor-isolated, что запрещает их передачу inout в async функции.
            let newDoc = await pdfProcessingService.processPDF(document: document, state: &localState)
            
            // 3. Обновляем `state` после выполнения
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
        savePanel.nameFieldStringValue = "processed_\(state.selectedFileName ?? "document").pdf"
        
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
