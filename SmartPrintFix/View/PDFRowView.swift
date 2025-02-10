//
//  PDFRowView.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 10.02.25.
//


import SwiftUI
import PDFKit

struct PDFRowView: View {
    var originalDocument: PDFDocument?
    var processedDocument: PDFDocument?
    var onDropHandler: ([NSItemProvider]) -> Bool
    
    var body: some View {
        HStack(spacing: 20) {
            // Левый PDF-документ
            VStack {
                if let originalDocument = originalDocument {
                    PDFKitView(document: originalDocument)
                } else {
                    Text("Drop a PDF here or select a file.")
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding()
                        .onDrop(of: ["public.file-url"], isTargeted: nil, perform: onDropHandler)
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
    }
}
