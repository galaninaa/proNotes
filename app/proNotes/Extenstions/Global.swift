//
//  Global.swift
//  proNotes
//
//  Created by Leo Thomas on 04/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

func between<T:Comparable>(_ value: T, min: T, max: T) -> T {
    if value < min {
        return min
    }

    if value > max {
        return max
    }

    return value
}

let π = CGFloat.pi
let standardAnimationDuration: Double = 0.2
