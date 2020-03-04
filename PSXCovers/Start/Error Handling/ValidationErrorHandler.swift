//
//  ValidationErrorHandler.swift
//  PSXCovers
//
//  Created by Digital on 25/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

class ValidationErrorHandler {
    func makeAlertController(for error: GameURLValidationError) -> UIAlertController {
        var message: String? = nil
        switch error {
        case .invalidURLString, .urlInitializationFailed, .urlComponentsInitializationFailed:
            message = "You've provided an invalid link. "
        case .hostIsNotPSXDC:
            message = "The link that you've provided is not a psxdatacenter.com link. "
        case .invalidPlatformSubpath:
            message = "The link that you've provided is not for a PSX game. "
                + "Please check your link, or try a different PSX game link."
        case .invalidRegionSubpath, .invalidAlphabetGroupSubpath, .invalidPSXGameSubpath:
            message = "The link that you've provided is not a valid PSX game link. "
                + "Please check your link and try again."
        }
        return UIAlertController.makeSimpleAlertWith(title: "URL Error", message: message)
    }
}
