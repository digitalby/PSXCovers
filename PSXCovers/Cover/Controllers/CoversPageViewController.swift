//
//  CoversPageViewController.swift
//  PSXCovers
//
//  Created by Digital on 28/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

class CoversPageViewController: UIPageViewController {

    var game: Game!
    var initialCoverIndex: Int!
    var flatCovers: [Cover] { game.coversGroupedByCategory.flatMap { $0 } }

    lazy var factory = CoverViewControllerFactory(storyboard: storyboard, transition: dismissTransition)
    lazy var helper = CoversPageViewControllerHelper(viewController: self)
    var dismissTransition: DismissTransitionInteractor? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = helper
        delegate = helper

        let cover = flatCovers[initialCoverIndex]
        var viewController: CoverViewController? = nil
        if initialCoverIndex == 0 {
            viewController = factory.makeLeadingCoverViewController(with: cover)
        } else if initialCoverIndex == flatCovers.count - 1 {
            viewController = factory.makeTrailingCoverViewController(with: cover)
        } else {
            viewController = factory.makeCoverViewController(with: cover)
        }
        guard let unwrappedViewController = viewController else { return }
        unwrappedViewController.topToolbarCenterItem.title = "\(initialCoverIndex + 1)/\(flatCovers.count)"
        setViewControllers([unwrappedViewController], direction: .forward, animated: false)
    }

    override var prefersStatusBarHidden: Bool {
        guard let viewController = currentCoverViewController else {
            return false
        }
        return viewController.prefersStatusBarHidden
    }
}

//MARK: - Helper
extension CoversPageViewController {
    var currentCoverViewController: CoverViewController? {
        viewControllers?.first as? CoverViewController
    }
}

//MARK: - Transitioning Delegate
extension CoversPageViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        DismissAnimator()
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        dismissTransition?.hasStarted == true ? dismissTransition : nil
    }
}
