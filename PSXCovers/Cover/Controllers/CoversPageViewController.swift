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

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self

        let cover = flatCovers[initialCoverIndex]
        guard let viewController = makeCoverViewController(with: cover) else { return }
        setViewControllers([viewController], direction: .forward, animated: false)
    }
}

//MARK: - View controller instantiation helper
extension CoversPageViewController {
    func makeCoverViewController(with cover: Cover) -> CoverViewController? {
        guard
            let storyboard = storyboard,
            let viewController = storyboard.instantiateViewController(identifier: "CoverViewController") as? CoverViewController
            else { return nil }

        viewController.cover = cover

        return viewController
    }
}

//MARK: - Page Data Source
extension CoversPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            let coverViewController = viewController as? CoverViewController,
            let cover = coverViewController.cover,
            let index = flatCovers.firstIndex(of: cover),
            (0..<flatCovers.count).contains(index - 1)
        else { return nil }

        let newViewController = makeCoverViewController(with: flatCovers[index - 1])

        return newViewController
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let coverViewController = viewController as? CoverViewController,
            let cover = coverViewController.cover,
            let index = flatCovers.firstIndex(of: cover),
            (0..<flatCovers.count).contains(index + 1)
        else { return nil }

        let newViewController = makeCoverViewController(with: flatCovers[index + 1])

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
}
