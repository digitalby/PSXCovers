//
//  CoverViewControllerGestureHandler.swift
//  PSXCovers
//
//  Created by Digital on 02/03/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

final class CoverViewControllerGestureHandler: NSObject, ViewControllerHelper, UIGestureRecognizerDelegate {
    weak var viewController: CoverViewController? = nil

    var displayingToolbars = true {
        didSet {
            viewController?.setNeedsStatusBarAppearanceUpdate()
            toolbarViews.forEach { $0.isHidden = !displayingToolbars }
            viewController?.setNeedsStatusBarAppearanceUpdate()
            toolbarViews.forEach { $0.updateConstraints() }
        }
    }
    var toolbarViews: [UIView] {
        guard let viewController = viewController else { return [] }
        return [
            viewController.bottomToolbar,
            viewController.bottomOverlayGradientImageView,
            viewController.bottomLabel,
            viewController.topToolbar
        ]
    }

    var isTrackingPanLocation = false
}

//MARK: - Delegate
extension CoverViewControllerGestureHandler {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer is UITapGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer)
            ||
            (gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UITapGestureRecognizer) {
            return false
        }
        return true
    }
}

//MARK: - Tap gesture recognizer
extension CoverViewControllerGestureHandler {
    func handle(tapGesture: UITapGestureRecognizer) {
        let newAlpha: CGFloat = !displayingToolbars ? 1.0 : 0.0
        if !displayingToolbars {
            displayingToolbars = true
        }
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.toolbarViews.forEach { $0.alpha = newAlpha }
        }) { [weak self] _ in
            if newAlpha == 0.0 { self?.displayingToolbars = false }
        }
    }
}

//MARK: - Pan gesture recognizer
extension CoverViewControllerGestureHandler {
    func handle(panGesture: UIPanGestureRecognizer) {
        guard let viewController = viewController else { return }
        let translation = panGesture.translation(in: viewController.view)
        if panGesture.state == .began && viewController.scrollView.contentOffset.y == 0 {
            isTrackingPanLocation = true
        } else if
            ![UIGestureRecognizer.State.ended, .cancelled, .failed].contains(panGesture.state),
            isTrackingPanLocation {
            if translation.y < 0 {
                isTrackingPanLocation = false
            }
        } else {
            isTrackingPanLocation = false
        }

        guard let dismissTransition = viewController.dismissTransition else { return }

        switch panGesture.state {
        case .cancelled:
            dismissTransition.hasStarted = false
            dismissTransition.cancel()
        case .ended:
            dismissTransition.hasStarted = false
            dismissTransition.shouldFinish ?
                dismissTransition.finish() :
                dismissTransition.cancel()
        default:
            break
        }

        guard isTrackingPanLocation else { return }

        let percentThreshold: CGFloat = 0.25

        let percentThresholdX: CGFloat = 0.1
        let horizontalMovement = abs(translation.x) / viewController.view.bounds.width

        let verticalMovement = translation.y / viewController.view.bounds.height
        let downwardMovement = max(verticalMovement, 0.0)
        let downwardMovementPercent = min(downwardMovement, 1.0)
        let progress = downwardMovementPercent

        switch panGesture.state {
        case .began:
            dismissTransition.hasStarted = true
            viewController.dismiss(animated: true, completion: nil)
        case .changed:
            if horizontalMovement > percentThresholdX {
                dismissTransition.cancel()
            } else {
            dismissTransition.shouldFinish = progress > percentThreshold
            dismissTransition.update(progress * 3.0)
            }
        default:
            break
        }

    }
}
