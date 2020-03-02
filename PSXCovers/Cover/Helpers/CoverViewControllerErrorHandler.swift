//
//  CoverViewControllerErrorHandler.swift
//  PSXCovers
//
//  Created by Digital on 02/03/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import Foundation

class CoverViewControllerErrorHandler {

    weak var viewController: CoverViewController? = nil

    init(viewController: CoverViewController) {
        self.viewController = viewController
    }

    func displayErrorViewWithGenericText() {
        displayErrorViewWithText("Cover download error.")
    }

    func displayErrorViewWithError(_ error: Error) {
        if let downloadError = error as? CoverImageDownloadError {
            var errorText: String!
            switch downloadError {
            case .requestAlreadyPresent:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    self?.viewController?.imageHandler.loadCoverImage()
                }
                return
            case .coverIsMissing:
                errorText = "This cover is unavailable.\nYou can help by adding it to psxdatacenter.com"
            case .responseError(_):
                errorText = "Can't load cover due to a network error."
            case .dataError:
                errorText = "The cover cannot be displayed."
            }
            displayErrorViewWithText(errorText)
        } else {
            displayErrorViewWithGenericText()
        }
    }

    func displayErrorViewWithText(_ errorText: String) {
        guard let viewController = viewController else { return }
        viewController.throbber.stopAnimating()
        viewController.imageErrorView.isHidden = false
        viewController.imageErrorView.errorLabel.text = errorText
    }
}
