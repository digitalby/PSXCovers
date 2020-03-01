//
//  CoverImageDownloader.swift
//  PSXCovers
//
//  Created by Digital on 28/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit
import Alamofire

class CoverImageDownloader {
    static let session = Session()

    func downloadImage(for cover: Cover, completion: ((UIImage?)->())? = nil) {
        guard
            cover.thumbnailImage != .missing,
            let url = cover.fullSizeImageURL
            else {
                completion?(nil)
                return
        }
        type(of: self).session.request(url).validate().response { response in
            guard
                response.error == nil,
                let data = response.data,
                let imageFromData = UIImage(data: data)
                else {
                    completion?(nil)
                    return
            }
            completion?(imageFromData)
        }
    }
}
