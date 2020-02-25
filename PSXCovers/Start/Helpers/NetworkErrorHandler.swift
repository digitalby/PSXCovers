//
//  NetworkErrorHandler.swift
//  PSXCovers
//
//  Created by Digital on 25/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit
import Alamofire

class NetworkErrorHandler {
    func makeAlertController(for error: Error) -> UIAlertController {
        var message: String? = nil
        if let error = error as? AFError {
            switch error {
            case .invalidURL(_):
                message = "The URL is not valid."
            case .parameterEncodingFailed(_), .multipartEncodingFailed(_):
                message = "Couldn't process the game page. The URL is most likely not for a PSX game."
            case .responseValidationFailed(let reason):
                message = "The response is not valid."
                switch reason {
                case .unacceptableStatusCode(let code):
                    message! += " Got error \(code)"
                    if code == 404 {
                        message! += " (the game probably does not exist - check your URL)"
                    }
                    message! += "."
                default:
                    message! += " PSXDC responded with improper data."
                }
            case .responseSerializationFailed(_):
                message = "The response cannot be processed."
            }
        } else {
            message = error.localizedDescription
        }
        let alert = UIAlertController(title: "Network Error", message: message, preferredStyle: .alert)
        let buttonOk = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(buttonOk)
        return alert
    }
}
