//
//  AppDependencies.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 15.02.25.
//

// Контейнер зависимостей

final class AppDependencies {
    static let shared = AppDependencies()
    
    let imageService: ImageProcessingServiceProtocol
    let pdfService: PDFProcessingServiceProtocol
    let fileService: FileServiceProtocol
    
    private init() {
        self.imageService = ImageProcessingService()
        self.fileService = FileService()
        self.pdfService = PDFProcessingService(
            imageProcessingService: imageService
        )
    }
}
