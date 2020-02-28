//
//  CoversPageViewController.swift
//  PSXCovers
//
//  Created by Digital on 28/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

class CoversPageViewController: UIPageViewController {

    var cover: Cover!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard
            let storyboard = storyboard,
            let viewController = storyboard.instantiateViewController(identifier: "CoverViewController") as? CoverViewController
            else { fatalError() }
        viewController.cover = cover
        setViewControllers([viewController], direction: .forward, animated: false)
    }
}
