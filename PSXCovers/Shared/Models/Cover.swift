//
//  Cover.swift
//  PSXCovers
//
//  Created by Digital on 25/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import Foundation

struct Cover {
    let thumbnailImageURL: URL?
    let fullSizeImageURL: URL?
    let coverCategory: String?
    let coverLabel: String?
}

extension Cover {
    var isMissing: Bool {
        let missingCoverURLString = "psxdatacenter.com/images/thumbs/none.jpg"
        if thumbnailImageURL?.absoluteString.range(of: missingCoverURLString) == nil {
            return false
        }
        return true
    }
}
