//
//  LogEntry.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 07.02.25.
//

import Foundation

struct LogEntry: Identifiable {
    let id = UUID()
    let message: String
}
