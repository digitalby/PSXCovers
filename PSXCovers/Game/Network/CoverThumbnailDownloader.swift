//
//  CoverThumbnailDownloader.swift
//  PSXCovers
//
//  Created by Digital on 28/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit
import Alamofire

class CoverThumbnailDownloader {
    static let session = Session()

    func downloadThumbnail(for cover: Cover, completion: ((UIImage?)->())? = nil) {
        var image: UIImage? = nil
        guard let coverURL = cover.thumbnailImageURL else {
            image = UIImage(named: "placeholder_error")
            completion?(image)
            return
        }
        guard !cover.isMissing else {
            image = UIImage(named: "placeholder_missing")
            completion?(image)
            return
        }
        type(of: self).session.request(coverURL).validate().response { response in
            guard
                response.error == nil,
                let data = response.data,
                let imageFromData = UIImage(data: data)
                else {
                    image = UIImage(named: "placeholder_error")
                    completion?(image)
                    return
            }
            image = imageFromData
            completion?(image)
        }
    }
}


