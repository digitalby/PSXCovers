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
        newViewController?.topToolbarCenterItem.title = "\(newIndex + 1)/\(flatCovers.count)"
        newViewController?.displayingToolbars = currentCoverViewController?.displayingToolbars ?? true
        setNeedsStatusBarAppearanceUpdate()
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
        newViewController?.topToolbarCenterItem.title = "\(newIndex + 1)/\(flatCovers.count)"
        newViewController?.displayingToolbars = currentCoverViewController?.displayingToolbars ?? true
        setNeedsStatusBarAppearanceUpdate()
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
