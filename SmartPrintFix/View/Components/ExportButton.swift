//
//  ExportButton.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 16.02.25.
//

import SwiftUI

struct ExportButton: View {
    let isEnabled: Bool
    let onAction: (ExportAction) -> Void
    
    @Binding var showingPopover: Bool 
    
    var body: some View {
        Button("Export") {
            showingPopover.toggle()
        }
        .frame(minWidth: 60)
        .disabled(!isEnabled)
        .popover(isPresented: $showingPopover) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(ExportAction.allCases, id: \.self) { action in
                    Button {
                        onAction(action)
                        showingPopover = false
                    } label: {
                        HStack {
                            Image(systemName: action.icon)
                            Text(action.title)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(4)
            .frame(minWidth: 150)
        }
    }
}
