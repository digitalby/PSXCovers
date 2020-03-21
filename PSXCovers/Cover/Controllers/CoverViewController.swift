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
    @IBOutlet var topToolbarCenterItem: UIBarButtonItem!
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
    lazy var imageHandler = CoverViewControllerImageHandler(viewController: self)
    lazy var errorHandler = CoverViewControllerErrorHandler(viewController: self)
    lazy var gestureHandler = CoverViewControllerGestureHandler(viewController: self)

    var dismissTransition: DismissTransitionInteractor? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        bottomLabel.text = cover.coverLabel

        scrollView.delegate = imageHandler

        tapGestureRecognizer.delegate = gestureHandler
        panGestureRecognizer.delegate = gestureHandler

        imageHandler.loadCoverImage()
    }

    override var prefersStatusBarHidden: Bool { !gestureHandler.displayingToolbars }
}

//MARK: - Actions
extension CoverViewController {
    @IBAction func didTapDone(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func didTapActionItem(_ sender: Any) {
        var array = [Any]()
        if let url = cover.fullSizeImageURL { array.append(url) }
        if let image = imageView.image { array.append(image) }
        guard !array.isEmpty else { return }

        let activityViewController = UIActivityViewController(activityItems: array, applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = topToolbarActionItem
        present(activityViewController, animated: true)
    }

    @IBAction func didRecognizeTapGesture(_ sender: UITapGestureRecognizer) {
        gestureHandler.handle(tapGesture: sender)
    }

    @IBAction func didRecognizePanGesture(_ sender: UIPanGestureRecognizer) {
        gestureHandler.handle(panGesture: sender)
    }
}
