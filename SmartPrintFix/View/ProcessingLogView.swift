//
//  ProcessingLogView.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 10.02.25.
//
import SwiftUI

struct ProcessingLogView: View {
    @Binding var logMessages: [LogEntry]
    @State private var isHoveringOverClear = false
    
    private enum Constants {
        static let spacing: CGFloat = 5
        static let padding: CGFloat = 16
        static let verticalPadding: CGFloat = 2
        static let cornerRadius: CGFloat = 10
        static let maxHeight: CGFloat = 150
        static let backgroundColor: Color = .gray.opacity(0.1)
        
        enum ClearButton {
            static let fontSize: CGFloat = 12
            static let horizontalPadding: CGFloat = 8
            static let verticalPadding: CGFloat = 4
            static let cornerRadius: CGFloat = 8
            static let offset: CGFloat = -16
            static let animationDuration: CGFloat = 0.3
        }
    }
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            logListView
            clearButtonView
        }
    }
}

// MARK: - Subviews
private extension ProcessingLogView {
    var logListView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.spacing) {
                ForEach(logMessages) { entry in
                    logEntryView(entry)
                }
            }
            .padding(Constants.padding)
        }
        .defaultScrollAnchor(.bottom)
        .frame(maxWidth: .infinity, maxHeight: Constants.maxHeight)
        .background(Constants.backgroundColor)
        .cornerRadius(Constants.cornerRadius)
    }
    
    func logEntryView(_ entry: LogEntry) -> some View {
        HStack {
            Text(entry.formattedMessage)
                .font(.caption)
                .foregroundColor(color(for: entry.type))
            Spacer()
        }
        .padding(.vertical, Constants.verticalPadding)
        .cornerRadius(Constants.cornerRadius)
    }
    
    @ViewBuilder
    var clearButtonView: some View {
        if !logMessages.isEmpty {
            Button(action: { logMessages.removeAll() }) {
                Text("Clear")
                    .font(.system(size: Constants.ClearButton.fontSize))
                    .foregroundColor(isHoveringOverClear ? .black : .gray)
                    .padding(.horizontal, Constants.ClearButton.horizontalPadding)
                    .padding(.vertical, Constants.ClearButton.verticalPadding)
                    .background(.clear)
                    .cornerRadius(Constants.ClearButton.cornerRadius)
            }
            .onHover { isHoveringOverClear = $0 }
            .accessibilityLabel("Clear logs")
            .offset(x: Constants.ClearButton.offset)
            .transition(.opacity)
            .animation(
                .easeInOut(duration: Constants.ClearButton.animationDuration),
                value: logMessages.isEmpty
            )
        }
    }
}

// MARK: - Helper Methods
private extension ProcessingLogView {
    func color(for type: LogEntry.LogType) -> Color {
        switch type {
        case .info: return .gray
        case .warning: return .orange
        case .error: return .red
        case .success: return .green
        }
    }
}
