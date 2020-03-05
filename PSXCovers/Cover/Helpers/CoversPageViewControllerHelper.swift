//
//  CoversPageViewControllerHelper.swift
//  PSXCovers
//
//  Created by Digital on 02/03/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

final class CoversPageViewControllerHelper: NSObject, ViewControllerHelper {
    weak var viewController: CoversPageViewController? = nil
}

//MARK: - Page Data Source
extension CoversPageViewControllerHelper: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            let coversPageViewController = self.viewController,
            let coverViewController = viewController as? CoverViewController,
            let cover = coverViewController.cover
            else { return nil }
        let flatCovers = coversPageViewController.flatCovers
        guard
            let index = flatCovers.firstIndex(of: cover)
            else { return nil }

        let newIndex = index - 1
        guard (0..<flatCovers.count).contains(newIndex) else { return nil }
        let newCover = flatCovers[newIndex]
        let newViewController = newIndex == 0 ?
            coversPageViewController.factory.makeLeadingCoverViewController(with: newCover) :
            coversPageViewController.factory.makeCoverViewController(with: newCover)
        newViewController?.topToolbarCenterItem.title = "\(newIndex + 1)/\(flatCovers.count)"
        return newViewController
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let coversPageViewController = self.viewController,
            let coverViewController = viewController as? CoverViewController,
            let cover = coverViewController.cover
            else { return nil }
        let flatCovers = coversPageViewController.flatCovers
        guard
            let index = flatCovers.firstIndex(of: cover)
            else { return nil }

        let newIndex = index + 1
        guard (0..<flatCovers.count).contains(newIndex) else { return nil }
        let newCover = flatCovers[newIndex]

        let newViewController = newIndex == flatCovers.count - 1 ?
            coversPageViewController.factory.makeTrailingCoverViewController(with: newCover) :
            coversPageViewController.factory.makeCoverViewController(with: newCover)
        newViewController?.topToolbarCenterItem.title = "\(newIndex + 1)/\(flatCovers.count)"
        return newViewController
    }

    private func prepare(newViewController: CoverViewController?) {
        let currentDisplayingToolbars = self.viewController?.currentCoverViewController?.gestureHandler.displayingToolbars
        newViewController?.gestureHandler.displayingToolbars = currentDisplayingToolbars ?? true
    }
}

//MARK: - Page Delegate
extension CoversPageViewControllerHelper: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pendingViewControllers.forEach { prepare(newViewController: ($0 as? CoverViewController)) }
    }
}
