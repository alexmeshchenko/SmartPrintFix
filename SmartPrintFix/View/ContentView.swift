//
//  ContentView.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 06.02.25.
//

import SwiftUI
import PDFKit

struct ContentView: View {
    @StateObject private var viewModel: PDFProcessingViewModel
    
    init(dependencies: AppDependencies = .shared) {
        let viewModel = PDFProcessingViewModel(
            pdfService: dependencies.pdfService,
            fileService: dependencies.fileService
        )
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            PDFRowView(
                originalDocument: viewModel.state.pdfDocument,
                processedDocument: viewModel.state.processedDocument,
                onDropHandler: viewModel.handleDrop,
                isProcessing: viewModel.state.isProcessing,
                onImport: viewModel.importPDF,
                onExport: viewModel.exportPDF
            )
            
            ProcessingLogView(logMessages: .constant(viewModel.state.logMessages))
        }
        .padding()
        .fileImporter(
            isPresented: $viewModel.showFilePicker,
            allowedContentTypes: [.pdf],
            onCompletion: viewModel.handleFileImport
        )
    }
}

#Preview {
    ContentView()
}
