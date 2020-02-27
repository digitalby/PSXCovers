//
//  CoverThumbnailCell.swift
//  PSXCovers
//
//  Created by Digital on 26/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

@IBDesignable class CoverThumbnailCell: UICollectionViewCell {
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var label: UILabel!
    @IBInspectable var cornerRadius: CGFloat = 0 {
       didSet {
           layer.cornerRadius = cornerRadius
           layer.masksToBounds = cornerRadius > 0
       }
    }
}
