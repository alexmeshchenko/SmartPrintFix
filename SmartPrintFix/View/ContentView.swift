//
//  ContentView.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 06.02.25.
//

import SwiftUI
import PDFKit
//import Vision

struct ContentView: View {
    @State private var state = PDFProcessingState()
    @State private var showFilePicker = false
    @State private var processedDocument: PDFDocument?
    
    var body: some View {
        VStack(spacing: 10) {
            
            // 1. Row of document views
            HStack(spacing: 20) {
                // Левый PDF-документ
                VStack {
                    if let pdfDocument = state.pdfDocument {
                        PDFKitView(document: pdfDocument)
                    } else {
                        Text("No file loaded. Please select a PDF.")
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Правый PDF-документ
                VStack {
                    if let processedDocument = processedDocument {
                        PDFKitView(document: processedDocument)
                    } else {
                        Text("Processed document will appear here.")
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            // 2. Row of buttons
            HStack(spacing: 20) {
                VStack {
                    Button(state.selectedFileName ?? "Select PDF") {
                        if !FileAccessUtility.checkDownloadsAccess() {
                            state.addLog("⚠️ No access to Downloads folder. Please grant permissions in System Preferences.")
                        }
                        showFilePicker = true
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Button("Save PDF") {
                        guard let document = processedDocument else { return }
                        savePDF(document: document)
                    }
                    .padding()
                    .disabled(processedDocument == nil)
                }
                .frame(maxWidth: .infinity)
            }
            
            // 3. Processing Button
            Button(action: {
                Task {
                    guard let document = state.pdfDocument else {
                        state.addLog("No PDF document loaded. Please select a file first.")
                        return
                    }
                    state.isProcessing = true
                    
                    // 1. Копируем состояние
                    var localState = state
                    
                    // 2. Запускаем обработку
                    // В Swift 6 изменились правила работы с @State, @Published и @Binding.
                    // Они теперь actor-isolated, что запрещает их передачу inout в async функции.
                    let newDoc = await PDFProcessingService.processPDF(document: document, state: &localState)
                    
                    // 3. Обновляем `state` после выполнения
                    DispatchQueue.main.async {
                        state = localState
                        processedDocument = newDoc
                        state.isProcessing = false
                    }
                }
            }) {
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
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(state.logMessages) { logEntry in
                            Text(logEntry.message)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: 150)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding()
                
                Button(action: {
                    state.logMessages.removeAll()
                }) {
                    Image(systemName: "trash")
                        .padding(10)
                        .background(Color.red.opacity(0.7))
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .padding()
                }
                .background(Color.clear)
            }// ZStack
            
        } // VStack
        .padding()
        .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.pdf]) { result in
            switch result {
            case .success(let url):
                state.pdfDocument = PDFDocument(url: url)
                state.selectedFileName = url.lastPathComponent
                if state.pdfDocument != nil {
                    state.addLog("File loaded successfully: \(state.selectedFileName ?? "Unknown")")
                } else {
                    state.addLog("Failed to load file: \(state.selectedFileName ?? "Unknown")")
                }
            case .failure(let error):
                state.addLog("Error selecting file: \(error.localizedDescription)")
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
