//
//  AppDependencies.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 15.02.25.
//

// Dependency container

final class AppDependencies {
    static let shared = AppDependencies()
    
    let imageService: ImageProcessingServiceProtocol
    let pdfService: PDFProcessingServiceProtocol
    let fileService: FileServiceProtocol
    
    private init() {
        self.fileService = FileService()
        self.imageService = ImageProcessingService()
        self.pdfService = PDFProcessingService(
            imageProcessingService: imageService
        )
    }
}
