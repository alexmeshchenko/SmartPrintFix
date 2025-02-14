//
//  MockImageProcessingService.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 10.02.25.
//

import PDFKit
import CoreImage
@testable import SmartPrintFix

/// A mock implementation of ImageProcessingService for testing
class MockImageProcessingService: ImageProcessingServiceProtocol {
    
    // MARK: - Configuration
    struct Configuration {
        var imageSize: CGSize = .init(width: 100, height: 100)
        var bitsPerComponent: Int = 8
        var shouldReturnNil = false
    }
    
    private(set) var configuration: Configuration
    
    // var shouldReturnNil = false
    // MARK: - Call Tracking
    private(set) var invertDarkAreasCalled = false
    private(set) var isAreaDarkCalled = false
    private(set) var providedPage: PDFPage?
    
    // MARK: - Initialization
    init(configuration: Configuration = .init()) {
        self.configuration = configuration
    }
    
    // MARK: - ImageProcessingServiceProtocol
    func invertDarkAreas(page: PDFPage) async -> CGImage? {
        invertDarkAreasCalled = true
        providedPage = page // Save the transferred page
        
        guard !configuration.shouldReturnNil,
              configuration.imageSize.width > 0,
              configuration.imageSize.height > 0 else {
            return nil
        }
        
        // Simulate image processing and isAreaDark call
        if let testContext = createTestContext(),
           let cgImage = testContext.makeImage() {
            _ = isAreaDark(CIImage(cgImage: cgImage))
        }
        
        return createTestImage()
    }
    
    func isAreaDark(_ image: CIImage) -> Bool {
        isAreaDarkCalled = true
        return true
    }
    
}

// MARK: - Private Helpers
private extension MockImageProcessingService {
    func createTestContext() -> CGContext? {
        CGContext(
            data: nil,
            width: Int(configuration.imageSize.width),
            height: Int(configuration.imageSize.height),
            bitsPerComponent: configuration.bitsPerComponent,
            bytesPerRow: Int(configuration.imageSize.width) * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
    }
    
    func createTestImage() -> CGImage? {
        createTestContext()?.makeImage()
    }
}

// MARK: - Testing Helpers
extension MockImageProcessingService {
    func reset() {
        invertDarkAreasCalled = false
        isAreaDarkCalled = false
        providedPage = nil
    }
    
    func configure(_ update: (inout Configuration) -> Void) {
        update(&configuration)
    }
}
