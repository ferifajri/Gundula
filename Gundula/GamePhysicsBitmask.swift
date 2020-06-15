//
//  GamePhysicsBitmask.swift
//  Gundula
//
//  Created by Feri Fajri on 11/06/20.
//  Copyright © 2020 Feri Fajri. All rights reserved.
//

import Foundation

public struct GamePhysicsBitmask {
    // Remember Bitmask is binary operation
    static let gacoan = 1 << 1 // Return 1, 2^0
    static let plane = 1 << 2 // Return 2, 2^1
    static let sasaran = 1 << 3 // Return 4, 2^2
    static let torus = 1 << 4 // Return 8, 2^3
    
    // Collision
    // gacoan : 2 | 4 = 6
    // sasaran : 1 | 2 | 4  = 7

    // Contact
    // gacoan : 4| 8 = 12
    // sasaran : 1 | 4 | 8 = 13

    //
}
