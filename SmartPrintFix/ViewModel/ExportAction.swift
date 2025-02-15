//
//  ExportAction.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 15.02.25.
//

import SwiftUI

enum ExportAction: CaseIterable {
    case preview
    case print
    case save
    
    var title: String {
        switch self {
        case .preview: return "Preview"
        case .print: return "Print"
        case .save: return "Save PDF"
        }
    }
    
    var icon: String {
        switch self {
        case .preview: return "eye"
        case .print: return "printer"
        case .save: return "arrow.down.doc"
        }
    }
    
    var shortcut: (key: KeyEquivalent, modifiers: EventModifiers) {
        switch self {
        case .preview: return ("p", [.command, .shift])
        case .print: return ("p", .command)
        case .save: return ("s", .command)
        }
    }
}
