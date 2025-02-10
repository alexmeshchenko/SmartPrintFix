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
    @State private var processedDocument: PDFDocument?
    
    // Инициализируем сервис
    private let pdfProcessingService = PDFProcessingService()
    
    var body: some View {
        VStack {
            
            // PDFRowView
            PDFRowView(
                originalDocument: state.pdfDocument,
                processedDocument: processedDocument,
                onDropHandler: handleDrop,
                isProcessing: state.isProcessing, // Передаем состояние
                    onImport: { showFilePicker = true },
                    onExport: {
                        if let doc = processedDocument {
                            savePDF(document: doc)
                        }
                    }
            )
            
            // Processing Log (Full Width)
            ProcessingLogView(logMessages: $state.logMessages)
            
        } // VStack
        .padding()
        .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.pdf]) { result in
            if !FileAccessUtility.checkDownloadsAccess() {
                state.addLog("⚠️ No access to Downloads folder. Please grant permissions in System Preferences.")
                return
            }
            
            switch result {
            case .success(let url):
                loadPDF(from: url)
            case .failure(let error):
                state.addLog("Error selecting file: \(error.localizedDescription)")
            }
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        state.addLog("handleDrop called with \(providers.count) provider(s).", type: .info) // Логируем вызов функции
        
        if let provider = providers.first {
            state.addLog("Processing first provider...", type: .info) // Логируем, что начали обработку первого провайдера
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (item, error) in
                if let data = item as? Data,
                   let url = URL(dataRepresentation: data, relativeTo: nil) {
                    DispatchQueue.main.async {
                        state.addLog("File dropped: \(url.lastPathComponent)", type: .info) // Логируем успешное получение файла
                        loadPDF(from: url)
                    }
                } else {
                    state.addLog("Failed to process the dropped file.", type: .error)
                }
            }
            return true
        }
        state.addLog("No valid provider found for the drop.", type: .warning) // Логируем, если провайдеров нет

        return false
    }
    
    private func loadPDF(from url: URL) {
        if state.isProcessing {
            state.addLog("Processing already in progress. Please wait for it to complete.", type: .warning)
            return
        }
        
        if let document = PDFDocument(url: url) {
            state.pdfDocument = document
            state.selectedFileName = url.lastPathComponent
            state.addLog("File loaded successfully: \(state.selectedFileName ?? "Unknown")")
            
            // Автоматически запускаем обработку после загрузки
            processPDF()
        } else {
            state.addLog("Failed to load PDF file.", type: .error)
        }
    }
    
    private func processPDF() {
        Task {
            guard let document = state.pdfDocument else {
                state.addLog("No PDF document loaded. Please select a file first.")
                return
            }
            state.isProcessing = true
            
            // 1. Копируем состояние
            var localState = state
            
            // 2. Запускаем обработку через инстанс сервиса
            // В Swift 6 изменились правила работы с @State, @Published и @Binding.
            // Они теперь actor-isolated, что запрещает их передачу inout в async функции.
            let newDoc = await pdfProcessingService.processPDF(document: document, state: &localState)
            
            // 3. Обновляем `state` после выполнения
            DispatchQueue.main.async {
                state = localState
                processedDocument = newDoc
                state.isProcessing = false
            }
        }
    }
    
    func savePDF(document: PDFDocument) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf]
        savePanel.nameFieldStringValue = "processed.pdf"
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                document.write(to: url)
                state.addLog("File saved: \(url.lastPathComponent)")
            } else {
                state.addLog("File saving canceled.")
            }
        }
    }
}

#Preview {
    ContentView()
}
