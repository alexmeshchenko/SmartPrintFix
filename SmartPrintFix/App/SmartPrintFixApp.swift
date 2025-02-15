//
//  SmartPrintFixApp.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 06.02.25.
//

import SwiftUI

@main
struct SmartPrintFixApp: App {
    // Инициализируем зависимости на уровне приложения
    /*
     Порядок импорта зависимостей важен:

     Сначала создаются базовые сервисы (ImageProcessingService, FileService)
     Затем сервисы, которые зависят от базовых (PDFProcessingService)
     */
    private let dependencies = AppDependencies.shared
    
    var body: some Scene {
        WindowGroup {
            //В конце инициализируется ViewModel, который использует все сервис
            ContentView(dependencies: dependencies)
        }
    }
}
