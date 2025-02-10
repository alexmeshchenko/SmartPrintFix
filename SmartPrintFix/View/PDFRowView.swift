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
    var isProcessing: Bool // Передаем состояние обработки
    var onImport: () -> Void
    var onExport: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            // Верхняя панель с информацией
            HStack(spacing: 8) {
                // Левая часть
                HStack(spacing: 0) {
                    if let path = originalDocument?.documentURL?.path {
                        Text(path)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    Spacer()
                    Button("Import", action: onImport)
                }
                .frame(maxWidth: .infinity)
                .onDrop(of: ["public.file-url"], isTargeted: nil, perform: onDropHandler)
                
                // Правая часть
                HStack(spacing: 0) {
                    Spacer()
                    Button("Export", action: onExport)
                        .disabled(processedDocument == nil)
                }
                .frame(maxWidth: .infinity)
            }
            
            // Существующий HStack с PDF-документами
            HStack(spacing: 8) {
                // Левый PDF-документ
                VStack(spacing: 0) {
                    if let originalDocument = originalDocument {
                        PDFKitView(document: originalDocument)
                            .onDrop(of: ["public.file-url"], isTargeted: nil, perform: onDropHandler)
                    } else {
                        
                        Text("Drop a PDF here or select a file.")
                            .frame(maxHeight: .infinity) // Добавляем это
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .onDrop(of: ["public.file-url"], isTargeted: nil, perform: onDropHandler)
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Правый PDF-документ
                ZStack {
                    VStack(spacing: 0) {
                        if let processedDocument = processedDocument {
                            PDFKitView(document: processedDocument)
                        } else {
                            Text("Processed document will appear here.")
                                .frame(maxHeight: .infinity) // Добавляем это
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Прогресс-бар, отображается поверх правого окна
                    if isProcessing {
                        ProgressView()
                            .scaleEffect(2) // Увеличиваем размер
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.4)) // Полупрозрачный фон
                            .cornerRadius(10)
                    }
                }
                .frame(maxWidth: .infinity)
            } // HStack -- Существующий HStack с PDF-документами
        }
    } // body
}
