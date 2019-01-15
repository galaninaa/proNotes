//
//  Pages.swift
//  proNotesUITests_AG
//
//  Created by Anton Galanin on 25/12/2018.
//  Copyright © 2018 leonardthomas. All rights reserved.
//

import XCTest

class Logger {
    func log(_ m: String) {
        //NSLog("Test Log: \(m)")
        print("Test Log: \(m)")
    }
}

class Page {
    typealias Completion = (() -> Void)?
    let app = XCUIApplication()
    let log = Logger().log
    required init(timeout: TimeInterval = 10, completion: Completion = nil) {
        log("waiting \(timeout)s for \(String(describing: self)) existence")
        XCTAssert(rootElement.waitForExistence(timeout: timeout),
                  "Page \(String(describing: self)) waited, but not loaded")
        completion?()
    }
    var rootElement: XCUIElement {
        fatalError("subclass should override rootElement")
    }
    var returnSystemButton: XCUIElement {
        return app.buttons["Return"]
    }
}

class MainPage: Page {
    let pageView = "proNotes.DocumentOverviewView"
    override var rootElement: XCUIElement {
        return app.navigationBars[pageView]
    }
    
    var documentsList: XCUIElementQuery {
        return app.collectionViews.textFields
    }
    
    var addButton: XCUIElement {
        return rootElement.buttons["Add"]
    }
    var deleteDocumentButton: XCUIElement {
        return app.menuItems["Delete"]
    }
    var renameDocumentButton: XCUIElement {
        return app.menuItems["Rename"]
    }
    // Creates and opens a document if the app is currently in the document overview
    ///
    /// - returns: the name of the new created document
    @discardableResult
    func createAndOpenDocument() -> String {
        return XCTContext.runActivity(named: "Create and open new document"){ _ in
            log("Create and open new document:")
            addButton.tap()
            log("  Add button was tapped")
            let documentName = DocumentPage().noteTitleTextField.value as! String
            log("  New document was opened")
            return documentName
        }
    }
    
    /// Deletes the document if the app is currently in the document overview
    ///
    /// - parameter name: of the document
    @discardableResult
    func deleteDocument(name: String) -> Self {
        XCTContext.runActivity(named: "Let's delete document with name '\(name)'") { _ in
            let documentCell = documentsList[name]
            documentCell.longPress()
            log("Long-tap was success")
            deleteDocumentButton.tap()
            log("Delete button was tapped")
            deleteValidation(name: name)
        }
        return self
    }
    
    @discardableResult
    func deleteValidation(name: String) -> Self {
        XCTContext.runActivity(named: "Validate delete document with name '\(name)'") { _ in
            let documentCell = documentsList
            if #available(iOS 10, *) {
                XCTContext.runActivity(named: "iOS 10+ is active") { _ in
                    XCTAssertFalse(documentCell[name].waitForExistence(timeout: 10), "Document wasn't deleted")
                }
            }
            else {
                XCTContext.runActivity(named: "iOS 9.3 is active") { _ in
                    XCTAssertEqual(documentCell[name].isHittable, false, "Document wasn't deleted")
                }
            }
            log("Document was not found in main screen. Deleted.")
        }
        return self
    }
    
    @discardableResult
    func renameDocument(name: String, newName: String) -> Self {
        XCTContext.runActivity(named: "Let's rename document '\(name)' to '\(newName)'") { _ in
            let documentCell = documentsList[name]
            documentCell.longPress()
            log("Long-tap was success")
            renameDocumentButton.tap()
            documentCell.doubleTap()
            documentCell.typeText("\(newName)\n")
            log("Document was renamed")
            renameValidation(newName: newName, oldName: name)
        }
//        XCTAssertFalse(documentCell.exists, "Document wasn't renamed")
//        XCTAssertTrue(documentsList[newName].exists, "Document with new name '\(newName)' wasn't found")
//        log("Document was successfully renamed")
        return self
    }
    
    @discardableResult
    func validateCreation(name: String) -> Self {
        XCTContext.runActivity(named: "Validate document creation") { _ in
            XCTAssertTrue(documentsList[name].exists, "Document with name \(name) wasn't created")
            log("Document was successfully created")
        }
        return self
    }

    /// Validation for document rename
    @discardableResult
    func renameValidation(newName: String, oldName: String) -> Self {
        XCTContext.runActivity(named: "Validate rename documents") { _ in
            XCTAssertTrue(documentsList[newName].exists,  "Document with new name '\(newName)' wasn't found")
            XCTAssertFalse(documentsList[oldName].exists,  "Document with old name '\(oldName)' was found")
            log("Document was successfully renamed")
        }
        return self
    }
    
    @discardableResult
    func dublicateValidation(firstDocumentName: String, secondDocumentName: String) -> Self {
        XCTContext.runActivity(named: "Validate dublicate documents") { _ in
            XCTAssertTrue(secondDocumentName != firstDocumentName, "Dublicate was found")
            log("No dublicate.")
        }
        return self
    }
    
    @discardableResult
    func openDocument(name: String) -> Self {
        XCTContext.runActivity(named: "Open document '\(name)'") { _ in
            documentsList[name].tap()
            log("Document opened")
        }
        return self
    }
    
    @discardableResult
    func createFewDocuments(count: Int) -> Self{
        XCTContext.runActivity(named: "Create \(count) document(s)") { _ in
            let array = [Int](1...count)
            log("We will create \(count) documents on Main page")
            for _ in array {
                MainPage()
                    .createAndOpenDocument()
                DocumentPage()
                    .closeDocument()
            }
            log("\(count) was created")
        }
        return self
    }
    
    @discardableResult
    func deleteAllDocuments() -> Self{
        return XCTContext.runActivity(named: "Delete all documents from main screen") { _ in
            var count: Int
            count = documentsList.count;
            
            log("We have \(count) documents on Main page")
            if #available(iOS 10, *) {
                let array = [Int](1...count)
                for _ in array {
                    let document = documentsList.allElementsBoundByIndex[0]
                    let docName = (document.value as? String)!
                    deleteDocument(name: docName)
                    log("Document \(docName) was deleted")
                    }
            }
            else {
                var indexOfDocument: Int
                indexOfDocument = count - 1
                let array = [Int](1...indexOfDocument)
                for _ in array {
                    let document = documentsList.allElementsBoundByIndex[indexOfDocument]
                    let docName = (document.value as? String)!
                    deleteDocument(name: docName)
                    log("Document \(docName) was deleted")
                    indexOfDocument = count - 1
                }
            }
            return self
        }
    }
}


class DocumentPage: Page {
    // View for "Document" page
    let pageView = "proNotes.DocumentView"
    override var rootElement: XCUIElement {
        return app.navigationBars[pageView]
    }
    var documentsButton: XCUIElement {
        return rootElement.buttons["Documents"]
    }
    var undoButton: XCUIElement {
        return rootElement.buttons["Undo"]
    }
    var noteTitleTextField: XCUIElement {
        return rootElement.textFields["note_title"]
    }
    var sketchButton: XCUIElement {
        return rootElement.buttons["sketchIcon"]
    }
    var addButton: XCUIElement {
        return rootElement.buttons["Add"]
    }
    var shareButton: XCUIElement {
        return rootElement.buttons["Share"]
    }
    var fullScreenOnButton: XCUIElement {
        return rootElement.buttons["fullscreenOn"]
    }
    var fullScreenOffButton: XCUIElement {
        return rootElement.buttons["fullscreenOff"]
    }
    var leftPannelView: XCUIElement {
        return app.tables["PagesOverViewTableView"]
    }
    var settingsPannelView: XCUIElement {
        return app.scrollViews.otherElements.containing(.staticText, identifier:"Page 1").element
    }
    var cancelButton: XCUIElement {
        return app.alerts.buttons["Cancel"]
    }
    var overrideButton: XCUIElement {
        return app.alerts.buttons["Override"]
    }
    var layerButton: XCUIElement {
        return rootElement.buttons["layerIcon"]
        //return rootElement.children(matching: .button).element(boundBy: 2)
    }
    
    @discardableResult
    func documentScreenValidation() -> Self {
        XCTContext.runActivity(named: "Validate Document screen") { _ in
            XCTAssertTrue(documentsButton.exists, "Document button doesnt exist")
            log("Documents button is shown")
            XCTAssertTrue(undoButton.exists, "Undo button doesnt exist")
            log("Undo button is shown")
            XCTAssertTrue(noteTitleTextField.exists, "Title  doesnt exist")
            log("Title is shown")
            XCTAssertTrue(sketchButton.exists, "Sketch button doesnt exist")
            log("Sketch icon is shown")
            XCTAssertTrue(addButton.exists, "Add button doesnt exist")
            log("Add icon is shown")
            XCTAssertTrue(shareButton.exists, "Share button doesnt exist")
            log("Share icon is shown")
            XCTAssertTrue(fullScreenOnButton.exists, "Full Screen button doesnt exist")
            log("Fullcreen icon is shown")
            // Left view pannel
            XCTAssertTrue(leftPannelView.exists, "PageOverViewLeftConstaraint doesnt exist")
            log("pagesOverViewLeftConstraint is shown")
            // Right view pannel
            XCTAssertTrue(settingsPannelView.exists, "SettingsViewController doesnt exist")
            log("SettingsViewController is shown")
        }
        return self
    }
    
    // Creates and opens a document if the app is currently in the document overview
    ///
    /// - returns: the name of the new created document
    @discardableResult
    func closeDocument() -> Self {
        XCTContext.runActivity(named: "Close document.") { _ in
            documentsButton.tap()
            log("Document closed")
        }
        return self
    }
    
    @discardableResult
    func headerValidation(name: String) -> Self {
        XCTContext.runActivity(named: "Validate Document header") { _ in
            XCTAssertTrue(noteTitleTextField.waitForExistence(timeout: 5))
            XCTAssertEqual(noteTitleTextField.value as? String, name)
            log("Document is OK")
        }
        return self
    }
    /// Renames the document if the document editor is currently opened
    ///
    /// - parameter newName: of the document
    
    @discardableResult
    func renameDocument(newName: String) -> Self{
        XCTContext.runActivity(named: "Rename Document in document view") { _ in
            let textField = noteTitleTextField
            textField.clearAndEnterText(newName + "\n")
            log("Document was successfully renamed in document view screen")
        }
        return self
    }
    
    @discardableResult
    func tapAddButton() -> Self {
        return XCTContext.runActivity(named: "Tap Add button") { _ in
            addButton.tap()
            log("Add button was tapped")
            return self
        }
    }
    
    @discardableResult
    func activateFullScreen() -> Self {
        return XCTContext.runActivity(named: "Tap Full Screen On button") { _ in
            fullScreenOnButton.tap()
            log("Fullscreen On button was tapped")
            return self
        }
    }
    
    @discardableResult
    func deactivateFullScreen() -> Self {
        return XCTContext.runActivity(named: "Tap Full Screen Off button") { _ in
            fullScreenOffButton.tap()
            log("Fullscreen Off button was tapped")
            return self
        }
    }
    
    @discardableResult
    func fullScreenOffValidation() -> Self {
        return XCTContext.runActivity(named: "Validate Full screen Off mode") { _ in
            XCTAssertTrue(fullScreenOnButton.exists, "Full screen On button wasn't found")
            XCTAssertTrue(leftPannelView.exists, "PageOverViewLeftConstaraint doesnt exist")
            XCTAssertTrue(settingsPannelView.exists, "SettingsViewController doesnt exist")
            log("Fullscreen is OFF")
            return self
        }
    }
    
    @discardableResult
    func fullScreenOnValidation() -> Self {
        return XCTContext.runActivity(named: "Validate Full screen On mode") { _ in
            XCTAssertTrue(fullScreenOffButton.exists, "Full screen Off button wasn't found")
            if #available(iOS 10, *) {
                XCTContext.runActivity(named: "iOS 10+ is active") { _ in
                    XCTAssertFalse(leftPannelView.exists, "PageOverViewLeftConstaraint is shown")
                    XCTAssertFalse(settingsPannelView.exists, "SettingsViewController is shown")
                }
            }
            else {
                XCTContext.runActivity(named: "iOS 9.3 is active") { _ in
                    XCTAssertFalse(settingsPannelView.isHittable, "SettingsViewController is hidden")
                    XCTAssertFalse(leftPannelView.isHittable, "PageOverViewLeftConstaraint is shown")
                }
            }
            log("Fullscreen is ON")
            return self
        }
    }
    
    @discardableResult
    func addSketch() -> Self {
        return XCTContext.runActivity(named: "Tap Add Sketch button") { _ in
            sketchButton.tap()
            sleep(2)
            log("Sketch button was tapped")
            return self
        }
    }
    
    @discardableResult
    func tapCancelButton() -> Self {
        return XCTContext.runActivity(named: "Tap Cancel button") { _ in
            cancelButton.tap()
            log("Cancel button was tapped")
            return self
        }
    }
    
    @discardableResult
    func tapOverrideButton() -> Self {
        return XCTContext.runActivity(named: "Tap Override button") { _ in
            overrideButton.tap()
            log("Override button was tapped")
            return self
        }
    }
    
    @discardableResult
    func tapLayersButton() -> Self {
        return XCTContext.runActivity(named: "Tap Layers button") { _ in
            layerButton.tap()
            log("Layers button was tapped")
            return self
        }
    }
    
}

class Layers: DocumentPage {
    override var rootElement: XCUIElement {
        return app/*@START_MENU_TOKEN@*/.scrollViews.otherElements["layerListView"]/*[[".scrollViews.otherElements[\"layerListView\"]",".otherElements[\"layerListView\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/
    }
    var textField: XCUIElement {
        return app.tables.staticTexts["Textfield"]
    }
    
    var sketckCancas: XCUIElement {
        return app.tables.staticTexts["Sketch Canvas"]
    }
    var image: XCUIElement {
        return app.tables.staticTexts["Image"]
    }
    var photo: XCUIElement {
        return app.tables.staticTexts["Photos"]
    }
    var emptyPage: XCUIElement {
        return app.tables.staticTexts["Empty Page"]
    }
    var deleteLayerButton: XCUIElement {
        return rootElement.tables.buttons["deleteLayerButton"]
    }
    var hideLayerButton: XCUIElement {
        return rootElement.tables.buttons["hideLayerButton"]
    }
    
    @discardableResult
    func layerValidation(type: String) -> Self {
        return XCTContext.runActivity(named: "Validate Layer screen") { _ in
            XCTAssertTrue(rootElement.tables.staticTexts[type].exists, "Layer \(type) doesnt exist")
            XCTAssertTrue(deleteLayerButton.exists, "Delete button doesnt exist")
            XCTAssertTrue(hideLayerButton.exists, "Hide Layer button doesnt exist")
            XCTAssertEqual(rootElement.tables.cells.matching(identifier: "LayerTableViewCell").count, 1)
            return self
        }
    }
    
    @discardableResult
    func noLayerValidation() -> Self {
        return XCTContext.runActivity(named: "Validate No Layer on page") { _ in
            XCTAssertFalse(deleteLayerButton.exists, "Delete button exist")
            XCTAssertFalse(hideLayerButton.exists, "Hide Layer button exist")
            XCTAssertEqual(rootElement.tables.cells.matching(identifier: "LayerTableViewCell").count, 0)
            return self
        }
    }
    
    @discardableResult
    func tapTextField() -> Self {
        return XCTContext.runActivity(named: "Tap Text Field") { _ in
            textField.tap()
            log("Text field was tapped")
            return self
        }
    }
    
    @discardableResult
    func tapSketchCanvas() -> Self {
        return XCTContext.runActivity(named: "Tap Sketch Canvas") { _ in
            sketckCancas.tap()
            log("Sketch Canvas was tapped")
            return self
        }
    }
    
    @discardableResult
    func tapEmptyPage() -> Self {
        return XCTContext.runActivity(named: "Tap Empty Page") { _ in
            emptyPage.tap()
            log("Epmty Page was tapped")
            return self
        }
    }
    
    @discardableResult
    func tapImage() -> Self {
        return XCTContext.runActivity(named: "Tap Image") { _ in
            image.tap()
            log("Image was tapped")
            return self
        }
    }
    
    @discardableResult
    func tapDeleteLayerButton() -> Self {
        return XCTContext.runActivity(named: "Tap Delete Layer button") { _ in
            deleteLayerButton.tap()
            log("Delete Layer Button was tapped")
            return self
        }
    }
    
    @discardableResult
    func addImagePhotoLayer() -> Self {
        return XCTContext.runActivity(named: "Add Image Layer with photo") { _ in
            tapImage()
            app.tables.staticTexts["Photos"].tap()
            let okButton = app.alerts.buttons["OK"]
            if okButton.exists {
                okButton.tap()
            }
            app.tables.buttons["Moments"].tap()
            app.collectionViews["PhotosGridView"].cells.element(boundBy: 0).tap()
            return self
        }
    }
    
    @discardableResult
    func validateImageLayer() -> Self {
        return XCTContext.runActivity(named: "Validate Image Layer") { _ in
            XCTAssertTrue(app/*@START_MENU_TOKEN@*/.scrollViews.otherElements["layerListView"]/*[[".scrollViews.otherElements[\"layerListView\"]",".otherElements[\"layerListView\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.staticTexts["image"].exists, "Image doesn't exists")
            XCTAssertEqual(app/*@START_MENU_TOKEN@*/.scrollViews.otherElements["layerListView"]/*[[".scrollViews.otherElements[\"layerListView\"]",".otherElements[\"layerListView\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.cells.matching(identifier: "LayerTableViewCell").count, 1)
            return self
        }
    }
    
    @discardableResult
    func tapHideLayerButton() -> Self {
        return XCTContext.runActivity(named: "Tap Hide Layer button") { _ in
            hideLayerButton.tap()
            log("Hide Layer Button was tapped")
            return self
        }
    }
    
}
    
class SketchSettings: DocumentPage {
    var buttonElements: XCUIElementQuery {
        return app.scrollViews.otherElements.buttons
    }
    var markerButton: XCUIElement {
        return buttonElements["markerIcon"]
    }
    var penButton: XCUIElement {
        return buttonElements["markerIcon"]
    }
    var eraseButton: XCUIElement {
        return buttonElements["markerIcon"]
    }

    @discardableResult
    func validateSketch() -> Self {
        return XCTContext.runActivity(named: "Validate Sketch settings screen") { _ in
            XCTAssertTrue(markerButton.exists, "Maerker button is not shown")
            XCTAssertTrue(penButton.exists, "Pen button is not shown")
            XCTAssertTrue(eraseButton.exists, "Erase button is not shown")
            return self
        }
    }
    
    @discardableResult
    func tapMarkerButton() -> Self {
        return XCTContext.runActivity(named: "Tap Marker button") { _ in
            markerButton.tap()
            log("Marker button was tapped")
            return self
        }
    }
    
    @discardableResult
    func tapPenButton() -> Self {
        return XCTContext.runActivity(named: "Tap Pen button") { _ in
            penButton.tap()
            log("Pen button was tapped")
            return self
        }
    }
    
    @discardableResult
    func tapEraseButton() -> Self {
        return XCTContext.runActivity(named: "Tap Erase button") { _ in
            eraseButton.tap()
            log("Erase button was tapped")
            return self
        }
    }

}

class PageCounter: DocumentPage {
    var pageCounterView: XCUIElementQuery {
        return app.tables.matching(identifier: "PagesOverViewTableView")
    }
    
    @discardableResult
    func validatePageTableView(pageNumber: Int) -> Self {
        return XCTContext.runActivity(named: "Validate Page Number counter") { _ in
            XCTAssertEqual(pageCounterView.cells.count, pageNumber, "Incorrect page number \(pageCounterView.cells.count). Expected: \(pageNumber)")
            return self
        }
    }
    
    @discardableResult
    func pageContainValidation(pageNumber: Int) -> Self {
        return XCTContext.runActivity(named: "Validate Page \(pageNumber) exists") { _ in
            XCTAssertTrue(app.scrollViews.otherElements.staticTexts["Page \(pageNumber)"].exists, "Page \(pageNumber) doesnt exist")
            return self
        }
    }
    
    @discardableResult
    func tapPage(pageNumber: Int) -> Self {
        return XCTContext.runActivity(named: "Tap page \(pageNumber)") { _ in
            pageCounterView.cells.containing(.staticText, identifier:"\(pageNumber)").children(matching: .button).element.tap()
            log("Page \(pageNumber) was tapped")
            return self
        }
    }
    
}
