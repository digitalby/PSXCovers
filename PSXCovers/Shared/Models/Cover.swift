//
//  Cover.swift
//  PSXCovers
//
//  Created by Digital on 25/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit
import RealmSwift

class Cover: Object {
    @objc dynamic private var _thumbnailImage: PersistentThumbnailImage? = nil
    var thumbnailImage: ThumbnailImage? {
        get { _thumbnailImage?.thumbnailImage }
        set {
            _thumbnailImage = PersistentThumbnailImage()
            _thumbnailImage?.thumbnailImage = newValue
        }
    }
    @objc dynamic private var _fullSizeImageData: Data? = nil
    var fullSizeImage: UIImage? {
        get {
            guard let data = _fullSizeImageData else { return nil }
            return UIImage(data: data)
        }
        set {
            let data = newValue?.jpegData(compressionQuality: 1.0)
            _fullSizeImageData = data
        }
    }
    @objc dynamic private var _thumbnailImageURL: String? = nil
    var thumbnailImageURL: URL? {
        get {
            URL(string: _thumbnailImageURL ?? "")
        }
        set {
            _thumbnailImageURL = newValue?.absoluteString
        }
    }
    @objc dynamic private var _fullSizeImageURL: String? = nil
    var fullSizeImageURL: URL? {
        get {
            URL(string: _fullSizeImageURL ?? "")
        }
        set {
            _fullSizeImageURL = newValue?.absoluteString
        }
    }
    @objc dynamic var coverCategory: String? = nil
    @objc dynamic var coverLabel: String? = nil

    convenience init(
        thumbnailImage: ThumbnailImage? = nil,
        fullSizeImage: UIImage? = nil,
        thumbnailImageURL: URL? = nil,
        fullSizeImageURL: URL? = nil,
        coverCategory: String? = nil,
        coverLabel: String? = nil
    ) {
        self.init()
        self.thumbnailImage = thumbnailImage
        self.fullSizeImage = fullSizeImage
        self.thumbnailImageURL = thumbnailImageURL
        self.fullSizeImageURL = fullSizeImageURL
        self.coverCategory = coverCategory
        self.coverLabel = coverLabel
    }
}

//extension Cover {
//    static func == (lhs: Cover, rhs: Cover) -> Bool {
//        return lhs.thumbnailImage == rhs.thumbnailImage &&
//            lhs.fullSizeImage == rhs.fullSizeImage &&
//            lhs.thumbnailImageURL == rhs.thumbnailImageURL &&
//            lhs.fullSizeImageURL == rhs.fullSizeImageURL &&
//            lhs.coverCategory == rhs.coverCategory &&
//            lhs.coverLabel == rhs.coverLabel
//    }
//}
