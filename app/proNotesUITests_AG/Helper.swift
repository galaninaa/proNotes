//
//  Helper.swift
//  proNotes
//
//  Created by Anton Galanin on 15/12/2018.
//  Copyright © 2018 leonardthomas. All rights reserved.
//

import XCTest

// From StackOverflow User bay.phillips http://stackoverflow.com/a/32894080

extension XCUIElement {
    
    /// Removes any current text in the field before typing in the new value
    ///
    /// - parameter text: the text to enter into the field
    func clearAndEnterText(_ text: String) -> Void {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }
        self.tap()
        var deleteString: String = ""
        for _ in stringValue.characters {
            deleteString += "\u{8}"
        }
        self.typeText(deleteString)
        self.typeText(text)
    }
    
    func setText(text: String, application: XCUIApplication) {
        UIPasteboard.general.string = text
        doubleTap()
        application.menuItems["Paste"].tap()
    }
    
    func longPress() {
        press(forDuration: 1)
    }
    
}

extension XCTestCase {
    func takeScreenShot(name screenshotName: String? = nil) {
        let screenshot = XCUIScreen.main.screenshot()
        let attach = XCTAttachment(screenshot: screenshot, quality: .original)
        attach.name = screenshotName ?? name + "_" + UUID().uuidString
        attach.lifetime = .keepAlways
        add(attach)
    }
}

