//
//  CoverViewController.swift
//  PSXCovers
//
//  Created by Digital on 28/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

class CoverViewController: UIViewController {

    @IBOutlet var imageErrorView: ImageErrorView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var throbber: UIActivityIndicatorView!

    @IBOutlet var topToolbar: UIToolbar!
    @IBOutlet var topToolbarDoneItem: UIBarButtonItem!
    @IBOutlet var topToolbarActionItem: UIBarButtonItem!

    @IBOutlet var bottomToolbar: UIToolbar!
    @IBOutlet var bottomOverlayGradientImageView: UIImageView!
    @IBOutlet var bottomLabel: UILabel!

    @IBOutlet var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var imageViewTrailingConstraint: NSLayoutConstraint!

    @IBOutlet var blackoutView: UIView!
    @IBOutlet var blackoutViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var blackoutViewTrailingConstraint: NSLayoutConstraint!

    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    var cover: Cover!
    let coverImageDownloader = CoverImageDownloader()

    var displayingToolbars = true {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
            toolbarViews.forEach { $0?.isHidden = !displayingToolbars }
        }
    }
    lazy var toolbarViews = [bottomToolbar, bottomOverlayGradientImageView, bottomLabel, topToolbar]

    var dismissTransition: DismissTransitionInteractor? = nil
    var isTrackingPanLocation = false

    override func viewDidLoad() {
        super.viewDidLoad()
        bottomLabel.text = cover.coverLabel
        loadCoverImage()
    }

    override var prefersStatusBarHidden: Bool { !displayingToolbars }
}

//MARK: - Displaying an image
extension CoverViewController {
    func loadCoverImage() {
        if cover.fullSizeImageURL != nil {
            coverImageDownloader.downloadImage(for: cover) { [weak self] image in
                guard let self = self else { return }
                if let image = image {
                    self.throbber.stopAnimating()
                    self.imageView.image = image
                    self.imageView.sizeToFit()
                    self.scrollView.contentSize = self.imageView.bounds.size
                    self.updateZoomScale()
                    self.updateImageViewConstraintsForSize(self.view.bounds.size)
                } else {
                    self.displayErrorView(errorText: "Cover download error.")
                }
            }
        } else if cover.isMissing {
            displayErrorView(errorText: "This cover is unavailable.\nYou can help by adding it to psxdatacenter.com")
        } else {
            self.displayErrorView(errorText: "Can't load cover.")
        }
    }

    func displayErrorView(errorText: String) {
        throbber.stopAnimating()
        imageErrorView.isHidden = false
        imageErrorView.errorLabel.text = errorText
    }

    func updateZoomScale() {
        let viewSize = view.bounds.size
        let widthScale = viewSize.width / imageView.bounds.width
        let heightScale = viewSize.height / imageView.bounds.height

        let minScale = min(widthScale, heightScale)

        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }

    func updateImageViewConstraintsForSize(_ size: CGSize) {
        let verticalSpace = size.height - imageView.frame.height

        let yOffset = max(0, verticalSpace / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset

        let horizontalSpace = size.width - imageView.frame.width
        let xOffset = max(0, horizontalSpace / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
    }
}

//MARK: - Scroll view delegate
extension CoverViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateImageViewConstraintsForSize(view.bounds.size)
    }
}

//MARK: - Pan gesture recognizer
extension CoverViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer, otherGestureRecognizer is UITapGestureRecognizer {
            return false
        }
        return true
    }

    @IBAction func didRecognizeTapGesture(_ sender: UITapGestureRecognizer) {
        let newAlpha: CGFloat = !displayingToolbars ? 1.0 : 0.0
        if !displayingToolbars {
            displayingToolbars = true
        }
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.toolbarViews.forEach { $0?.alpha = newAlpha }
        }) { [weak self] _ in
            if newAlpha == 0.0 { self?.displayingToolbars = false }
        }
    }

    @IBAction func didRecognizePanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        if sender.state == .began && scrollView.contentOffset.y == 0 {
            sender.setTranslation(.zero, in: scrollView)
            isTrackingPanLocation = true
        } else if
            ![UIGestureRecognizer.State.ended, .cancelled, .failed].contains(sender.state),
            isTrackingPanLocation {
            if translation.y < 0 {
                isTrackingPanLocation = false
            }
        } else {
            isTrackingPanLocation = false
        }

        guard let dismissTransition = dismissTransition else { return }

        switch sender.state {
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

        let percentThreshold: CGFloat = 0.1

        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = max(verticalMovement, 0.0)
        let downwardMovementPercent = min(downwardMovement, 1.0)
        let progress = downwardMovementPercent

        switch sender.state {
        case .began:
            dismissTransition.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            dismissTransition.shouldFinish = progress > percentThreshold
            dismissTransition.update(progress * 3.0)
        default:
            break
        }
    }
}

//MARK: - Actions
extension CoverViewController {
    @IBAction func didTapDone(_ sender: Any) {
        dismiss(animated: true)
    }
}
