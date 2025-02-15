//
//  SmartPrintFixApp.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 06.02.25.
//

import SwiftUI

@main
struct SmartPrintFixApp: App {
    // Initialize dependencies at the application level
    /*
     The order of dependency imports is important:

     First, the basic services are created (ImageProcessingService, FileService).
     Then, services that depend on the basic ones are created (PDFProcessingService).
     */

    private let dependencies = AppDependencies.shared
    
    var body: some Scene {
        WindowGroup {
            // Finally, the ViewModel is initialized, which uses all the services
            ContentView(dependencies: dependencies)
        }
    }
}
