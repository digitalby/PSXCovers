//
//  CoverThumbnailDownloader.swift
//  PSXCovers
//
//  Created by Digital on 28/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit
import Alamofire

private let missingCoverURLString = "psxdatacenter.com/images/thumbs/none.jpg"

class CoverThumbnailDownloader {
    static let session = Session()

    func downloadThumbnail(for cover: Cover, completion: ((ThumbnailImage)->())? = nil) {
        guard let coverURL = cover.thumbnailImageURL else {
            completion?(.error)
            return
        }
        guard coverURL.absoluteString.range(of: missingCoverURLString) == nil else {
            completion?(.missing)
            return
        }
        type(of: self).session.request(coverURL).validate().response { response in
            guard
                response.error == nil,
                let data = response.data,
                let imageFromData = UIImage(data: data)
                else {
                    completion?(.error)
                    return
            }
            completion?(.with(imageFromData))
        }
    }
}


