//
//  Cover.swift
//  PSXCovers
//
//  Created by Digital on 25/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

enum ThumbnailImage: Equatable {
    case error
    case missing
    case with(UIImage)
}

class Cover {
    var thumbnailImage: ThumbnailImage?
    var fullSizeImage: UIImage?
    let thumbnailImageURL: URL?
    let fullSizeImageURL: URL?
    let coverCategory: String?
    let coverLabel: String?

    init(
        thumbnailImage: ThumbnailImage? = nil,
        fullSizeImage: UIImage? = nil,
        thumbnailImageURL: URL? = nil,
        fullSizeImageURL: URL? = nil,
        coverCategory: String? = nil,
        coverLabel: String? = nil
    ) {
        self.thumbnailImage = thumbnailImage
        self.fullSizeImage = fullSizeImage
        self.thumbnailImageURL = thumbnailImageURL
        self.fullSizeImageURL = fullSizeImageURL
        self.coverCategory = coverCategory
        self.coverLabel = coverLabel
    }
}

extension Cover: Equatable {
    static func == (lhs: Cover, rhs: Cover) -> Bool {
        return lhs.thumbnailImage == rhs.thumbnailImage &&
            lhs.fullSizeImage == rhs.fullSizeImage &&
            lhs.thumbnailImageURL == rhs.thumbnailImageURL &&
            lhs.fullSizeImageURL == rhs.fullSizeImageURL &&
            lhs.coverCategory == rhs.coverCategory &&
            lhs.coverLabel == rhs.coverLabel
    }
}
