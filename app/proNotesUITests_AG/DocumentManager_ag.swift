//
//  DocumentManagerUITests_ag
//  proNotes
//
//  Created by Anton Galanin on 25/12/2018.
//  Copyright © 2018 leonardthomas. All rights reserved.
//

import XCTest

class DocumentManagerUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["UITEST"]
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testDocumentScreenValidation(){
        
        let documentName = MainPage()
            .createAndOpenDocument()
        DocumentPage()
            .documentScreenValidation()
            .closeDocument()
        MainPage()
            .deleteDocument(name: documentName)
        
    }
    
    func testCreateAndDeleteDocument() {
        let documentName = MainPage()
            .createAndOpenDocument()
        DocumentPage()
            .closeDocument()
        MainPage()
            .validateCreation(name: documentName)
            .deleteDocument(name: documentName)
    }
    
    func testRenameDocumentOnMainScreen() {
        let newName = UUID().uuidString
        let documentName = MainPage()
            .createAndOpenDocument()
        DocumentPage()
            .closeDocument()
        MainPage()
            .validateCreation(name: documentName)
            .renameDocument(name: documentName, newName: newName)
            .deleteDocument(name: newName)
    }
    
    func testForDuplicates() {
        let documentName = MainPage()
            .createAndOpenDocument()
        DocumentPage()
            .closeDocument()
        let newDocumentName = MainPage()
            .createAndOpenDocument()
        DocumentPage()
            .closeDocument()
        MainPage()
            .dublicateValidation(firstDocumentName: documentName, secondDocumentName: newDocumentName)
            .deleteDocument(name: documentName)
            .deleteDocument(name: newDocumentName)
    }
    
    func testRename() {
        let documentName = MainPage()
            .createAndOpenDocument()
        let newName = UUID().uuidString
        DocumentPage()
            .renameDocument(newName: newName)
            .closeDocument()
        MainPage()
            .renameValidation(newName: newName, oldName: documentName)
            .deleteDocument(name: newName)
    }
    
    func testValidateFullScreenOff(){
        let documentName = MainPage()
            .createAndOpenDocument()
        DocumentPage()
            .documentScreenValidation()
            .fullScreenOffValidation()
            .closeDocument()
        MainPage()
            .deleteDocument(name: documentName)
    }
    
    func testValidateFullScreenOn(){
        let documentName = MainPage()
            .createAndOpenDocument()
        DocumentPage()
            .documentScreenValidation()
            .activateFullScreen()
            .fullScreenOnValidation()
            .deactivateFullScreen()
            .fullScreenOffValidation()
            .closeDocument()
        MainPage()
            .deleteDocument(name: documentName)
        
    }
    
    func testRenameOverride() {
        let documentName = MainPage()
            .createAndOpenDocument()
        DocumentPage()
            .closeDocument()
        let newName = MainPage()
            .createAndOpenDocument()
        DocumentPage()
            .closeDocument()
        MainPage()
            .openDocument(name: newName)
        DocumentPage()
            .renameDocument(newName: documentName )
            .tapCancelButton()
            .headerValidation(name: newName)
            .closeDocument()
        MainPage()
            .validateCreation(name: newName)
            .validateCreation(name: documentName)
            .openDocument(name: documentName)
        DocumentPage()
            .renameDocument(newName: newName )
            .tapOverrideButton()
            .headerValidation(name: newName)
            .closeDocument()
        MainPage()
            .deleteValidation(name: documentName)
            .validateCreation(name: newName)
            .deleteDocument(name: newName)
    }

    @available(iOS 10,*)
    func testDeleteAllDocuments() {
        MainPage()
            .createFewDocuments(count:10)
        MainPage()
            .deleteAllDocuments()
    }
}
