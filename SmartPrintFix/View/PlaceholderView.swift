//
//  PlaceholderView.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 14.02.25.
//

import SwiftUI

struct PlaceholderView: View {
    let text: String // Text to display
    let icon: String? // Optional icon
    @State private var isAnimating = false // Animation state

    // Initializer with a default value for icon
    init(text: String, icon: String? = nil) {
        self.text = text
        self.icon = icon
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if let iconName = icon { // If an icon is provided
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray.opacity(0.7))
                    .scaleEffect(isAnimating ? 1.1 : 1.0) // Pulsing animation
                    .onAppear {
                        // Start animation manually using a timer
                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                            withAnimation(.easeInOut(duration: 1.0)) {
                                isAnimating.toggle()
                            }
                        }
                    }
            } else {
                // Placeholder block (100x100) if no icon is provided
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 100, height: 100)
            }
            Text(text)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .font(.title3)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}
