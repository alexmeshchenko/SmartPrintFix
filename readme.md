![Platform](https://img.shields.io/badge/platform-macOS-lightgrey)
![macOS](https://img.shields.io/badge/macOS-14.0+-blue)
![Swift](https://img.shields.io/badge/Swift-6.0-orange)
# 🖨️ SmartPrintFix
SmartPrintFix is a **macOS application** that **automatically processes PDF documents before printing**.  
It **inverts dark areas** in PDFs (such as code blocks with dark backgrounds) to make them **more printer-friendly** when printing on light paper.

## 📌 Features
✅ Load and preview PDF documents,  
✅ **Automatic processing** (invert dark areas for better printing),  
✅ View **both original and processed PDFs** side by side,  
✅ Save processed PDFs,  
✅ Maintain a **processing log**,  
✅ Drag and drop support,
✅ Real-time processing status.

## 🏗️ Architecture (MVSU)
The project follows the **Model-View-Service-Utility (MVSU)** architecture:

📂 SmartPrintFix 
├── 📂 Model # Application state and data models
│   ├── PDFProcessingState.swift # Processing state management
│   ├── LogEntry.swift # Logging system model
├── 📂 View # SwiftUI Interface
│   ├── ContentView.swift # Main view container
│   ├── PDFKitView.swift # PDF rendering view
│   ├── PDFRowView.swift # PDF comparison view
│   ├── ProcessingLogView.swift # Log display view
├── 📂 Service # Core business logic
│   ├── PDFProcessingService.swift # PDF document processing
│   ├── ImageProcessingService.swift # Image analysis and conversion
├── 📂 Utility # Support functions
│   ├── FileAccessUtility.swift # File system operations
│   ├── SmartPrintFixApp.swift # Application entry point
├── 📂 Tests
│   ├── ImageProcessingTests.swift # Image processing tests
│   ├── PDFProcessingTests.swift # PDF processing tests
│   ├── UITests # UI automation tests

### Architecture Details
- **Model**: Handles state management and data structures
- **View**: SwiftUI-based user interface components
- **Service**: Core business logic and processing
- **Utility**: Helper functions and system interactions

## 💻 System Requirements
- macOS 14.0 (Sonoma) or later
- Apple Silicon or Intel processor
- Xcode 16+ for development

## 🚀 Installation
1. Ensure your Mac meets the system requirements:
   - macOS 14.0 or later
   - Apple Silicon or Intel processor
2. Install Xcode 16+ from the Mac App Store
3. Clone the repository:
   ```shell
   git clone https://github.com/yourusername/SmartPrintFix.git
   cd SmartPrintFix```
4. Open SmartPrintFix.xcodeproj in Xcode
5. Build and run the project on macOS

## 🛠️ Technologies Used
- Swift 6
- SwiftUI (User Interface)
- PDFKit (PDF handling)
- Vision Framework (Image analysis)
- XCTest (Testing)

## 🧪 Testing
The project includes comprehensive test coverage:

- Unit tests for image processing
- Unit tests for PDF processing
- UI automation tests
- Performance tests

## 📜 License
This project is licensed under the MIT License.

## 📸 Screenshots (Example UI)
Original PDF    Processed PDF

## 💡 Developer
Author: [Your Name]
Contact: [Your email or GitHub]

## 📢 Future Plans
🔹 Dark mode support
🔹 Add OCR to recognize text in code sections
🔹 Integrate with Quick Look for previewing PDFs
🔹 Batch processing support
🔹 Processing presets
🔹 Export/Import settings
