//
//  CoverViewControllerImageHandler.swift
//  PSXCovers
//
//  Created by Digital on 02/03/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

final class CoverViewControllerImageHandler: NSObject, ViewControllerHelper {
    weak var viewController: CoverViewController? = nil
}

//MARK: - Displaying an image
extension CoverViewControllerImageHandler {
    func loadCoverImage() {
        guard let viewController = viewController else { return }
        guard let cover = viewController.cover else {
            viewController.errorHandler.displayErrorViewWithGenericText()
            return
        }
        if let image = cover.fullSizeImage {
            viewController.throbber.stopAnimating()
            viewController.imageView.image = image
            viewController.imageView.sizeToFit()
            viewController.scrollView.contentSize = viewController.imageView.bounds.size
            updateZoomScale()
            updateImageViewConstraintsForSize(viewController.view.bounds.size)
            viewController.topToolbarActionItem.isEnabled = true
            return
        }
        viewController.coverImageDownloader.downloadImage(for: cover) { [weak cover, weak self] image, error in
            if let error = error {
                self?.viewController?.errorHandler.displayErrorViewWithError(error)
                return
            }
            if let image = image {
                cover?.fullSizeImage = image
                self?.loadCoverImage()
            }
        }
    }

    func updateZoomScale() {
        guard let viewController = viewController else { return }
        let viewSize = viewController.view.bounds.size
        let widthScale = viewSize.width / viewController.imageView.bounds.width
        let heightScale = viewSize.height / viewController.imageView.bounds.height

        let minScale = min(widthScale, heightScale)

        viewController.scrollView.minimumZoomScale = minScale
        viewController.scrollView.zoomScale = minScale
    }

    func updateImageViewConstraintsForSize(_ size: CGSize) {
        guard let viewController = viewController else { return }
        let verticalSpace = size.height - viewController.imageView.frame.height

        let yOffset = max(0, verticalSpace / 2)
        viewController.imageViewTopConstraint.constant = yOffset
        viewController.imageViewBottomConstraint.constant = yOffset

        let horizontalSpace = size.width - viewController.imageView.frame.width
        let xOffset = max(0, horizontalSpace / 2)
        viewController.imageViewLeadingConstraint.constant = xOffset
        viewController.imageViewTrailingConstraint.constant = xOffset
    }
}

//MARK: - Scroll view delegate
extension CoverViewControllerImageHandler: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { viewController?.imageView }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard let viewController = viewController else { return }
        updateImageViewConstraintsForSize(viewController.view.bounds.size)
    }
}
