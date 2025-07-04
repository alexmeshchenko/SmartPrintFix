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

## 🏗️ Architecture (MVVM + Service-Utility)
The project follows an extended **Model-View-ViewModel** architecture with additional Service and Utility layers:
```
📂 SmartPrintFix
├── 📂 App # Application root
│   ├── AppDependencies.swift # Dependency container
│   ├── SmartPrintFixApp.swift # Entry point
├── 📂 Model # Data layer
│   ├── States
│   │   ├── PDFProcessingState.swift # Processing state
│   │   └── LogEntry.swift # Logging model
│   └── Errors
│       └── FileError.swift # File operation errors
├── 📂 ViewModel # Presentation layer
│   └── PDFProcessingViewModel.swift # Main view model
├── 📂 View # UI layer
│   ├── ContentView.swift # Main container
│   ├── PDFKitView.swift # PDF rendering
│   ├── PDFRowView.swift # PDF comparison
│   ├── PlaceholderView.swift # Empty state
│   └── ProcessingLogView.swift # Log display
├── 📂 Service # Business logic layer
│   ├── PDF
│   │   ├── PDFProcessingService.swift # PDF processing
│   │   └── PDFProcessingServiceProtocol.swift # Service interface
│   ├── Image
│   │   ├── ImageProcessingService.swift # Image processing
│   │   └── ImageProcessingServiceProtocol.swift # Service interface
│   └── File
│       ├── FileService.swift # File operations
│       ├── FileServiceProtocol.swift # Service interface
│       └── FileDirectory.swift # Directory types
├── 📂 Utility # Support layer
│   └── FileAccessUtility.swift # File system access
├── 📂 Tests
│   ├── ImageProcessingTests.swift # Image processing tests
│   ├── PDFProcessingTests.swift # PDF processing tests
│   └── UITests # UI automation tests
```

### Architecture Details
- **App**: Application configuration and dependency injection
- **Model**: Pure data models and state definitions
- **ViewModel**: Presentation logic and state management
- **View**: SwiftUI interface components
- **Service**: Core business logic and processing
- **Utility**: Support functions and system interactions

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
- Combine Framework
- XCTest (Testing)

## 🧪 Testing
The project includes comprehensive test coverage:

- Unit tests for services
- ViewModel tests
- Integration tests
- UI tests

## 📜 License
This project is licensed under the MIT License.

## 📸 Screenshots (Example UI)
Original PDF    Processed PDF

## 💡 Developer
Author: Aleksandr Meshchenko
Contact: alex.meshchenko@gmail.com
GitHub: @alexmeshchenko

## 📢 Future Plans
🔹 Dark mode support  
🔹 Add OCR to recognize text in code sections  
🔹 Integrate with Quick Look for previewing PDFs  
🔹 Batch processing support  
🔹 Processing presets  
🔹 Export/Import settings
