//
//  AddLayerUITests.swift
//  proNotes
//
//  Created by Anton Galanin on 15/12/2018.
//  Copyright © 2018 leonardthomas. All rights reserved.
//

import XCTest

class AddLayerUITests: XCTestCase {
    
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
    
    func testCreateTextLayer() {
        let documentName = MainPage()
            .createAndOpenDocument()
        DocumentPage()
            .tapAddButton()
        Layers()
            .tapTextField()
        DocumentPage()
            .tapLayersButton()
        Layers()
            .layerValidation(type: "text")
        DocumentPage()
            .closeDocument()
        MainPage()
            .deleteDocument(name: documentName)
    }
    

    func testCreateSketchCanvas() {
        let documentName = MainPage()
            .createAndOpenDocument()
        DocumentPage()
            .tapAddButton()
        Layers()
            .tapSketchCanvas()
        DocumentPage()
            .tapLayersButton()
        Layers()
            .layerValidation(type: "sketch")
        DocumentPage()
            .closeDocument()
        MainPage()
            .deleteDocument(name: documentName)
    }
    
    func testValidateSketchSettings() {
        let documentName = MainPage()
            .createAndOpenDocument()
        DocumentPage()
            .addSketch()
        SketchSettings()
            .validateSketch()
            .tapEraseButton()
            .tapPenButton()
            .tapMarkerButton()
        DocumentPage()
            .closeDocument()
        MainPage()
            .deleteDocument(name: documentName)
        
    }
    
    func testCreatePage() {
       let documentName = MainPage()
            .createAndOpenDocument()
        PageCounter()
            .validatePageTableView(pageNumber: 1)
            .pageContainValidation(pageNumber: 1)
        DocumentPage()
            .tapAddButton()
        Layers()
            .tapEmptyPage()
        PageCounter()
            .tapPage(pageNumber: 2)
            .validatePageTableView(pageNumber: 2)
            .pageContainValidation(pageNumber: 2)
        DocumentPage()
            .closeDocument()
        MainPage()
            .deleteDocument(name: documentName)
    }
    
    func testCreateImageLayer() {
        let documentName = MainPage()
            .createAndOpenDocument()
        DocumentPage()
            .tapAddButton()
        Layers()
            .addImagePhotoLayer()
        DocumentPage()
            .tapLayersButton()
        Layers()
            .validateImageLayer()
        DocumentPage()
            .closeDocument()
        MainPage()
            .deleteDocument(name: documentName)
    }
}

