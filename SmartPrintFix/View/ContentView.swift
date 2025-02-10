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
            
            // 1. Row of document views
            // Используем новый компонент PDFRowView
            PDFRowView(
                originalDocument: state.pdfDocument,
                processedDocument: processedDocument,
                onDropHandler: handleDrop
            )
            
            // 2. Row of buttons
            HStack(spacing: 20) {
                // Кнопка выбора PDF
                
                Button(state.selectedFileName ?? "Select PDF") {
                    if !FileAccessUtility.checkDownloadsAccess() {
                        state.addLog("⚠️ No access to Downloads folder. Please grant permissions in System Preferences.")
                    }
                    showFilePicker = true
                }
                .padding()
                .frame(maxWidth: .infinity)
                
                // Кнопка сохранения
                Button("Save PDF") {
                    guard let document = processedDocument else { return }
                    savePDF(document: document)
                }
                .padding()
                .disabled(processedDocument == nil)
                .frame(maxWidth: .infinity)
            }
            
            // Кнопка обработки
            // 3. Processing Button
            Button(action: processPDF) {
                HStack {
                    if state.isProcessing {
                        ProgressView()
                    }
                    Text("Process")
                }
            }
            .padding()
            .disabled(state.isProcessing)
            
            // 4. Processing Log (Full Width)
            ProcessingLogView(logMessages: $state.logMessages)
            
        } // VStack
        .padding()
        .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.pdf]) { result in
            switch result {
            case .success(let url):
                loadPDF(from: url)
            case .failure(let error):
                state.addLog("Error selecting file: \(error.localizedDescription)")
            }
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        if let provider = providers.first {
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (item, error) in
                if let data = item as? Data,
                   let url = URL(dataRepresentation: data, relativeTo: nil) {
                    DispatchQueue.main.async {
                        loadPDF(from: url)
                    }
                } else {
                    state.addLog("Failed to process the dropped file.", type: .error)
                }
            }
            return true
        }
        return false
    }
    
    private func loadPDF(from url: URL) {
        if let document = PDFDocument(url: url) {
            state.pdfDocument = document
            state.selectedFileName = url.lastPathComponent
            state.addLog("File loaded successfully: \(state.selectedFileName ?? "Unknown")")
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
