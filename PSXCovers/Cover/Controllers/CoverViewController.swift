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
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var throbber: UIActivityIndicatorView!
    @IBOutlet var topToolbar: UIToolbar!
    @IBOutlet var topToolbarCloseItem: UIBarButtonItem!

    var cover: Cover!
    let coverImageDownloader = CoverImageDownloader()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCoverImage()
    }

    func loadCoverImage() {
        if cover.fullSizeImageURL != nil {
            coverImageDownloader.downloadImage(for: cover) { [weak self] image in
                guard let self = self else { return }
                if let image = image {
                    self.throbber.stopAnimating()
                    self.imageView.image = image
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
}

//MARK: - Actions
extension CoverViewController {
    @IBAction func didTapDone(_ sender: Any) {
        dismiss(animated: true)
    }
}
