//
//  NumberExtension.swift
//  Capitaine spot
//
//  Created by 2Gather Arnaud Verrier on 10/04/2017.
//  Copyright © 2017 Arnaud Verrier. All rights reserved.
//

import Foundation

public extension Int {
    public static func random (lower: Int , upper: Int) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
}

public extension Double {
    public static var random:Double {
        get {
            return Double(arc4random()) / 0xFFFFFFFF
        }
    }
    public static func random(min: Double, max: Double) -> Double {
        return Double.random * (max - min) + min
    }
}
