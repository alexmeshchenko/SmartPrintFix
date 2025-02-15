//
//  FileDirectory.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 15.02.25.
//

import Foundation

enum FileDirectory {
    case downloads
    case documents
    case temporary
    
    var url: URL? {
        switch self {
        case .downloads:
            return FileManager.default.urls(
                for: .downloadsDirectory,
                in: .userDomainMask
            ).first
            
        case .documents:
            return FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first
            
        case .temporary:
            return FileManager.default.temporaryDirectory
        }
    }
}
