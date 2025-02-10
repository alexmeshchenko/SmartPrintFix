//
//  ProcessingLogView.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 10.02.25.
//
import SwiftUI

struct ProcessingLogView: View {
    @Binding var logMessages: [LogEntry]
    
    @State private var isHoveringOverTrash: Bool = false // Для отслеживания наведения
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(logMessages) { logEntry in
                        HStack {
                            Text(logEntry.formattedMessage)
                                .font(.caption)
                                .foregroundColor(color(for: logEntry.type))
                            Spacer()
                        }
                        .padding(.vertical, 2)
                        .cornerRadius(5)
                    }
                }
                .padding()
            }
            .defaultScrollAnchor(.bottom)
            .frame(maxWidth: .infinity, maxHeight: 150)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            // Кнопка очистки логов
            if !logMessages.isEmpty {
                Button(action: {
                    logMessages.removeAll()
                }) {
                    Text("Clear")
                        .font(.system(size: 12))
                        .foregroundColor(isHoveringOverTrash ? .black : .gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isHoveringOverTrash ? Color.orange.opacity(0.2) : Color.clear)
                        .cornerRadius(8)
                }
                .onHover { hovering in
                    isHoveringOverTrash = hovering
                }
                .accessibilityLabel("Очистить логи") // Описание для доступности
                .offset(x: -16, y: 0) // Смещение кнопки на 4 пикселя влево
                .transition(.opacity) // Плавное появление и исчезновение
                .animation(.easeInOut(duration: 0.3), value: logMessages.isEmpty) // Анимация с длительностью 0.3 секунды
            }
        }
    }
    
    private func color(for type: LogEntry.LogType) -> Color {
        switch type {
        case .info: return .gray
        case .warning: return .orange
        case .error: return .red
        case .success: return .green
        }
    }
}
