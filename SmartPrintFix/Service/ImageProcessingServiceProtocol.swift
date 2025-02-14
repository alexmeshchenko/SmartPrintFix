//
//  ImageProcessingServiceProtocol.swift
//  SmartPrintFix
//
//  Created by Aleksandr Meshchenko on 10.02.25.
//

import CoreGraphics
import CoreImage
import PDFKit

/// Image Processing Service Protocol
protocol ImageProcessingServiceProtocol {
    /// Inverts dark areas on PDF page
    /// - Parameter page: PDF page for processing
    /// - Returns: Processed image in CGImage format, or nil if error
    ///
    /// Guarantees:
    /// - Returns nil if:
    ///   - page has incorrect dimensions (width or height <= 0)
    ///   - could not create image from page
    ///   - An error occurred during image processing
    /// - Maintains original image size and characteristics
    /// - Thread-safe.
    func invertDarkAreas(page: PDFPage) async -> CGImage?
    
    /// Determines whether the image area is dark
    /// - Parameter image: Image for analysis
    /// - Returns: true if the area is considered dark
    ///
    /// The implementations must:
    /// - Use a matching algorithm to determine dark areas
    /// - Correctly handle different color spaces
    /// - Consider the overall brightness of the image
    func isAreaDark(_ image: CIImage) async -> Bool
}

extension ImageProcessingServiceProtocol {
    // Recommended brightness threshold for dark area
    static var darknessTreshold: Double { 0.4 }
}
