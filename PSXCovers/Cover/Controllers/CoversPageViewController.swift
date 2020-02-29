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
    var dismissTransition: DismissTransitionInteractor? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self

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
        setViewControllers([unwrappedViewController], direction: .forward, animated: false)
    }
}

//MARK: - Page Data Source
extension CoversPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            let coverViewController = viewController as? CoverViewController,
            let cover = coverViewController.cover,
            let index = flatCovers.firstIndex(of: cover)
        else { return nil }

        let newIndex = index - 1
        guard (0..<flatCovers.count).contains(newIndex) else { return nil }
        let newCover = flatCovers[newIndex]
        let newViewController = newIndex == 0 ?
            factory.makeLeadingCoverViewController(with: newCover) :
            factory.makeCoverViewController(with: newCover)

        return newViewController
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let coverViewController = viewController as? CoverViewController,
            let cover = coverViewController.cover,
            let index = flatCovers.firstIndex(of: cover)
        else { return nil }

        let newIndex = index + 1
        guard (0..<flatCovers.count).contains(newIndex) else { return nil }
        let newCover = flatCovers[newIndex]

        let newViewController = newIndex == flatCovers.count - 1 ?
            factory.makeTrailingCoverViewController(with: newCover) :
            factory.makeCoverViewController(with: newCover)

        return newViewController
    }
}

//MARK: - Page Delegate
extension CoversPageViewController: UIPageViewControllerDelegate {

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
