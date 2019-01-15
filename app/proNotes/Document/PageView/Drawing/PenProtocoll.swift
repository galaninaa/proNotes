//
//  PenProtocoll.swift
//  proNotes
//
//  Created by Leo Thomas on 27/03/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

protocol Pen: class {
    var lineWidth: CGFloat { get set }
    var alphaValue: CGFloat { get }
    var enabledShading: Bool { get }
    var isEraser: Bool { get }
}

class Pencil: Pen {
    var lineWidth: CGFloat = 5
    var alphaValue: CGFloat = 1
    var enabledShading: Bool = false
    var isEraser: Bool = false
}

class Marker: Pen {
    var lineWidth: CGFloat = 20
    var alphaValue: CGFloat = 0.5
    var enabledShading = true
    var isEraser: Bool = false
}

class Eraser: Pen {
    var lineWidth: CGFloat = 10
    var alphaValue: CGFloat = 1
    var isEraser: Bool = true
    var enabledShading: Bool = false
}