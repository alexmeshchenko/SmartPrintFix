# 🖨️ SmartPrintFix

SmartPrintFix is a **macOS application** designed to **automatically process PDF documents before printing**.  
It **inverts dark areas** in PDFs (e.g., code blocks with black backgrounds) to make them **more printer-friendly** on light backgrounds.

## 📌 Features
✅ Load and preview PDF documents  
✅ **Automatic processing** (invert dark areas for better printing)  
✅ View **both original and processed PDFs** side by side  
✅ Save processed PDFs  
✅ Maintain a **processing log**  

## 🏗️ Architecture (MVSU)
The project follows the **Model-View-Service-Utility (MVSU)** architecture:


📂 SmartPrintFix 
├── 📂 Model # Manages application state 
│   ├── PDFProcessingState.swift 
│   ├── LogEntry.swift 
├── 📂 View # UI (SwiftUI) 
│   ├── ContentView.swift 
│   ├── PDFKitView.swift 
├── 📂 Service # PDF processing logic 
│   ├── PDFProcessingService.swift 
│   ├── ImageProcessingService.swift 
├── 📂 Utility # Utility functions (permissions, file access, etc.) 
│   ├── FileAccessUtility.swift 
│   ├── SmartPrintFixApp.swift # Application entry point


## 🚀 Installation
1. Ensure you have **Xcode 16+** installed  
2. Clone the repository:
   ```sh
   git clone https://github.com/yourusername/SmartPrintFix.git
   cd SmartPrintFix


3. Open SmartPrintFix.xcodeproj in Xcode
4. Build and run the project on macOS


🛠️ Technologies Used
Swift 6
SwiftUI (User Interface)
PDFKit (PDF handling)
MVSU (Architectural pattern)

📜 License
This project is licensed under the MIT License.

📸 Screenshots (Example UI)
Original PDF    Processed PDF

💡 Developer
Author: [Your Name]
Contact: [Your email or GitHub]

📢 TODO (Future Plans)
🔹 Dark mode support
🔹 Add OCR to recognize text in code sections
🔹 Integrate with Quick Look for previewing PDFs

