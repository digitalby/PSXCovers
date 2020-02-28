//
//  CoverViewController.swift
//  PSXCovers
//
//  Created by Digital on 28/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

class CoverViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var throbber: UIActivityIndicatorView!
    @IBOutlet var topToolbar: UIToolbar!
    @IBOutlet var topToolbarCloseItem: UIBarButtonItem!

    var cover: Cover!
    var noImage = true
    let coverImageDownloader = CoverImageDownloader()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCoverImage()
    }

    func loadCoverImage() {
        let errorAccessory = UIImage(named: "accessory_error")
        if cover.fullSizeImageURL != nil {
            coverImageDownloader.downloadImage(for: cover) { [unowned self] image in
                self.throbber.stopAnimating()
                if let image = image {
                    self.imageView.image = image
                    self.noImage = false
                } else {
                    self.imageView.image = errorAccessory
                }
            }
        } else {
            throbber.stopAnimating()
            imageView.image = errorAccessory
        }
    }
}

//MARK: - Actions
extension CoverViewController {
    @IBAction func didTapDone(_ sender: Any) {
        dismiss(animated: true)
    }
}
