//
//  CoverViewControllerFactory.swift
//  PSXCovers
//
//  Created by Digital on 29/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

class CoverViewControllerFactory {

    let storyboard: UIStoryboard?
    let transition: DismissTransitionInteractor?

    init(storyboard: UIStoryboard? = nil, transition: DismissTransitionInteractor? = nil) {
        self.storyboard = storyboard
        self.transition = transition
    }

    func makeCoverViewController(with cover: Cover) -> CoverViewController? {
        guard
            let viewController = storyboard?.instantiateViewController(identifier: "CoverViewController") as? CoverViewController
            else { return nil }

        viewController.cover = cover
        viewController.dismissTransition = transition

        viewController.loadViewIfNeeded()

        return viewController
    }

    func makeLeadingCoverViewController(with cover: Cover) -> CoverViewController? {
        let controller = makeCoverViewController(with: cover)
        controller?.blackoutViewLeadingConstraint.constant = -5000
        return controller
    }

    func makeTrailingCoverViewController(with cover: Cover) -> CoverViewController? {
        let controller = makeCoverViewController(with: cover)
        controller?.blackoutViewTrailingConstraint.constant = 5000
        return controller
    }
}
