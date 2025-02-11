//
//  SmartPrintFixUITestsLaunchTests.swift
//  SmartPrintFixUITests
//
//  Created by Aleksandr Meshchenko on 06.02.25.
//

import XCTest

final class SmartPrintFixUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Делаем скриншот
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        // Восстанавливаем Light Mode
        if let script = NSAppleScript(source: "tell application \"System Events\" to tell appearance preferences to set dark mode to false") {
            var error: NSDictionary?
            script.executeAndReturnError(&error)
        }
    }
}
