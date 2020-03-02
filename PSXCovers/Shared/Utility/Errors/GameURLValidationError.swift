//
//  GameURLValidationError.swift
//  PSXCovers
//
//  Created by Digital on 02/03/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import Foundation

enum GameURLValidationError: Error {
    case invalidURLString
    case urlInitializationFailed
    case urlComponentsInitializationFailed
    case hostIsNotPSXDC
    case invalidPlatformSubpath
    case invalidRegionSubpath
    case invalidAlphabetGroupSubpath
    case invalidPSXGameSubpath
}
