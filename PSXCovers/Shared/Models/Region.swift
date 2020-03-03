//
//  Region.swift
//  PSXCovers
//
//  Created by Digital on 25/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import Foundation

enum Region: String {
    case pal
    case ntscU
    case ntscJ

    init?(fromString string: String) {
        let capsString = string.uppercased()
        switch capsString {
        case "PAL":
            self = .pal
        case "NTSC-U":
            self = .ntscU
        case "NTSC-J":
            self = .ntscJ
        default:
            return nil
        }
    }
}

extension Region {
    var stringValue: String {
        switch self {
        case .pal:
            return "PAL"
        case .ntscU:
            return "NTSC-U"
        case .ntscJ:
            return "NTSC-J"
        }
    }
}
