//
//  CoverThumbnailCellConfigurator.swift
//  PSXCovers
//
//  Created by Digital on 02/03/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

class CoverThumbnailCellConfigurator {
    class func configure(_ cell: CoverThumbnailCell, with cover: Cover) {
        if let coverImage = cover.thumbnailImage {
            switch coverImage {
            case .error:
                cell.thumbnailImageView.image = ImageConstants.placeholderError
                break
            case .missing:
                cell.thumbnailImageView.image = ImageConstants.placeholderMissing
                break
            case .with(let image):
                cell.thumbnailImageView.image = image
                break
            }
        } else {
            cell.thumbnailImageView.image = ImageConstants.placeholderLoading
        }
    }
}
