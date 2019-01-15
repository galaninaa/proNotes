//
//  LayerTableViewUITests_ag.swift
//  proNotesUITests_AG
//
//  Created by Anton Galanin on 27/12/2018.
//  Copyright © 2018 leonardthomas. All rights reserved.
//


import XCTest

class LayerTableViewUITests: XCTestCase {
    
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
    
    func testDeleteLayer() {
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
            .tapDeleteLayerButton()
            .noLayerValidation()
        DocumentPage()
            .closeDocument()
        MainPage()
            .deleteDocument(name: documentName)
    }
}
