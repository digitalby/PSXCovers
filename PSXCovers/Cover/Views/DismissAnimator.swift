//
//  DismissAnimator.swift
//  PSXCovers
//
//  Created by Digital on 29/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { 1 / 3 }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let viewController = transitionContext.viewController(forKey: .from) as? UIPageViewController
        let child = viewController?.viewControllers?.first
        UIView.animate(withDuration: 1 / 3, animations: {
            child?.view.alpha = 0.0
        }, completion: {_ in
            child?.view.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
    }


}
