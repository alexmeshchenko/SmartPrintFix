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
    @State private var pdfDocument: PDFDocument?
    @State private var showFilePicker = false
    @State private var selectedFileName: String?
    @State private var isProcessing = false
    @State private var logMessages: [String] = []
    
    var body: some View {
        VStack {
            if let pdfDocument = pdfDocument {
                PDFKitView(document: pdfDocument)
            } else {
                Text("Select a PDF file to process")
            }
            
            if let fileName = selectedFileName {
                Text("Selected file: \(fileName)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Button("Select PDF") {
                if !checkDownloadsAccess() {
                    logMessages.append("⚠️ No access to Downloads folder. Please grant permissions in System Preferences.")
                }
                showFilePicker = true
            }
            .padding()
            
            Button("Process and Save PDF") {
                Task {
                    guard let document = pdfDocument else {
                        logMessages.append("No PDF document loaded. Please select a file first.")
                        return
                    }
                    isProcessing = true
                    logMessages.append("Processing started...")
                    await processPDF(document: document)
                    logMessages.append("Processing completed.")
                    isProcessing = false
                }
            }
            .padding()
            .disabled(isProcessing) // Отключаем кнопку во время обработки
            
            if isProcessing {
                ProgressView()
                    .padding()
            }
            // Логирование
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(logMessages, id: \.self) { message in
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(height: 100)
        }
        .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.pdf]) { result in
            switch result {
            case .success(let url):
                print("Selected file URL: \(url.absoluteString)")
                
                if url.startAccessingSecurityScopedResource() {
                    defer { url.stopAccessingSecurityScopedResource() } // Освобождаем доступ после использования
                    
                    if let pdfData = try? Data(contentsOf: url) {
                        pdfDocument = PDFDocument(data: pdfData)
                        logMessages.append("Loaded via Data(contentsOf:)")
                    } else {
                        logMessages.append("Failed to load file via Data(contentsOf:)")
                    }
                } else {
                    logMessages.append("No permission to access file: \(url.lastPathComponent)")
                }

                selectedFileName = url.lastPathComponent
                if pdfDocument != nil {
                    logMessages.append("File loaded successfully: \(selectedFileName ?? "Unknown")")
                } else {
                    logMessages.append("Failed to load file: \(selectedFileName ?? "Unknown")")
                    print("Error: PDFDocument is nil. File may be corrupted.")
                }

            case .failure(let error):
                logMessages.append("Error selecting file: \(error.localizedDescription)")
            }
        }
    }
    
    func checkDownloadsAccess() -> Bool {
        let testFile = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?
            .appendingPathComponent("test_access.txt")
        
        if let testFile = testFile {
            do {
                try "Test".write(to: testFile, atomically: true, encoding: .utf8)
                try FileManager.default.removeItem(at: testFile) // Удаляем тестовый файл
                return true
            } catch {
                return false // Нет доступа
            }
        }
        return false
    }

    
    func processPDF(document: PDFDocument) async {
        let newDocument = PDFDocument()
        
        for i in 0..<document.pageCount {
            if let page = document.page(at: i) {
                logMessages.append("Processing page \(i + 1) of \(document.pageCount)...")
                
                if let processedCGImage = await invertDarkAreas(page: page) {
                    let processedImage = NSImage(cgImage: processedCGImage, size: page.bounds(for: .mediaBox).size)
                    
                    if let newPage = PDFPage(image: processedImage) {
                        newDocument.insert(newPage, at: i)
                        logMessages.append("Page \(i + 1) processed.")
                    } else {
                        logMessages.append("Failed to create new page for page \(i + 1).")
                    }
                } else {
                    logMessages.append("Skipping page \(i + 1): processing failed.")
                }
            }
        }
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf]
        savePanel.nameFieldStringValue = "processed.pdf"
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                newDocument.write(to: url)
                logMessages.append("File saved: \(url.lastPathComponent)")
            } else {
                logMessages.append("File saving canceled.")
            }
        }
    }
    
    func invertDarkAreas(page: PDFPage) async -> CGImage? {
        let image = page.thumbnail(of: page.bounds(for: .mediaBox).size, for: .mediaBox)
        
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let cgImage = bitmap.cgImage else { return nil }
        
        return await processImage(cgImage: cgImage)
    }
    
    func processImage(cgImage: CGImage) async -> CGImage? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let context = CIContext()
                let ciImage = CIImage(cgImage: cgImage)
                let invertFilter = CIFilter(name: "CIColorInvert")
                invertFilter?.setValue(ciImage, forKey: kCIInputImageKey)
                
                if let outputImage = invertFilter?.outputImage,
                   let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) {
                    continuation.resume(returning: outputCGImage)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
