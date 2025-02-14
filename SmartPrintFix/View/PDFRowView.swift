//
//  PDFRowView.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 10.02.25.
//

import SwiftUI
import PDFKit

/// A view that displays original and processed PDF documents side by side
struct PDFRowView: View {
    /// Layout and style constants
    private enum Constants {
        // Layout
        static let spacing: CGFloat = 8
        static let cornerRadius: CGFloat = 10
        
        // Visual
        static let placeholderOpacity: CGFloat = 0.2
        static let progressScaleFactor: CGFloat = 2
        static let progressBackgroundOpacity: CGFloat = 0.4
    }
    
    let originalDocument: PDFDocument?
    let processedDocument: PDFDocument?
    let onDropHandler: ([NSItemProvider]) -> Bool
    let isProcessing: Bool
    let onImport: () -> Void
    let onExport: () -> Void
    
    var body: some View {
        VStack(spacing: Constants.spacing) {
            toolbarView
            documentContainerView
        }
    }
    
    // MARK: - Toolbar Components
    
    private var toolbarView: some View {
        HStack(spacing: Constants.spacing) {
            originalDocumentToolbar
            processedDocumentToolbar
        }
    }
    
    private var originalDocumentToolbar: some View {
        HStack {
            documentPath
            Spacer()
            Button("Import", action: onImport)
        }
        .frame(maxWidth: .infinity)
        .onDrop(of: [.fileURL], isTargeted: nil, perform: onDropHandler)
    }
    
    private var documentPath: some View {
        Group {
            if let path = originalDocument?.documentURL?.path {
                Text(path)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
    }
    
    private var processedDocumentToolbar: some View {
        HStack {
            Spacer()
            Button("Export", action: onExport)
                .disabled(processedDocument == nil)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Document Views
    
    private var documentContainerView: some View {
        HStack(spacing: Constants.spacing) {
            originalDocumentView
            processedDocumentView
        }
    }
    
    /// Left side view displaying the original PDF
    private var originalDocumentView: some View {
        VStack(spacing: 0) {
            if let document = originalDocument {
                PDFKitView(document: document)
            } else {
                PlaceholderView(text: "Drop a PDF here or select a file.", icon: "document.badge.plus")
            }
        }
        .frame(maxWidth: .infinity)
        .onDrop(of: [.fileURL], isTargeted: nil, perform: onDropHandler)
    }
    
    /// Right side view displaying the processed PDF with processing overlay
    private var processedDocumentView: some View {
        ZStack {
            VStack(spacing: 0) {
                if let document = processedDocument {
                    PDFKitView(document: document)
                } else {
                    PlaceholderView(text: "Processed document will appear here.")
                }
            }
            
            if isProcessing {
                processingOverlay
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Helper Views
    private var processingOverlay: some View {
        ProgressView()
            .scaleEffect(Constants.progressScaleFactor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(Constants.progressBackgroundOpacity))
            .cornerRadius(Constants.cornerRadius)
    }
}
