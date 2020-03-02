//
//  CoverImageDownloader.swift
//  PSXCovers
//
//  Created by Digital on 28/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit
import Alamofire

enum CoverImageDownloadError: Error {
    case requestAlreadyPresent
    case coverIsMissing
    case responseError(Error)
    case dataError
}

typealias DownloadCompletion = (UIImage?, Error?)->()

class CoverImageDownloader {
    static let session = Session()
    static var pendingURLs = Set<URL>()

    func downloadImage(for cover: Cover, completion: DownloadCompletion? = nil) {
        guard
            cover.thumbnailImage != .missing,
            let url = cover.fullSizeImageURL
            else {
                completion?(nil, CoverImageDownloadError.coverIsMissing)
                return
        }
        let removePendingAndComplete: DownloadCompletion = { image, error in
            type(of: self).pendingURLs.remove(url)
            completion?(image, error)
        }
        guard !type(of: self).pendingURLs.contains(url) else {
            completion?(nil, CoverImageDownloadError.requestAlreadyPresent)
            return
        }
        type(of: self).pendingURLs.insert(url)
        type(of: self).session.request(url).validate().response { response in
            if let error = response.error {
                removePendingAndComplete(nil, CoverImageDownloadError.responseError(error))
                return
            }
            guard
                let data = response.data,
                let imageFromData = UIImage(data: data)
                else {
                    removePendingAndComplete(nil, CoverImageDownloadError.dataError)
                    return
            }
            removePendingAndComplete(imageFromData, nil)
        }
    }
}
