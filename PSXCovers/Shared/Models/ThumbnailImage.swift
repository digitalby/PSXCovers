//
//  ThumbnailImage.swift
//  PSXCovers
//
//  Created by Digital on 04/03/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit
import RealmSwift

enum ThumbnailImage: Equatable {
    case error // error
    case missing // missing
    case with(UIImage) // with

    func toPersistent() -> (String?, UIImage?) {
        switch self {
        case .error:
            return ("error", nil)
        case .missing:
            return ("missing", nil)
        case .with(let image):
            return ("with", image)
        }
    }

    static func fromPersistent(stringValue: String?, with: UIImage?) -> Self? {
        switch stringValue {
        case "error":
            return .error
        case "missing":
            return .missing
        case "with":
            guard let with = with else { return nil }
            return .with(with)
        default:
            return nil
        }
    }
}

class PersistentThumbnailImage: Object {
    @objc dynamic private var _withData: Data? = nil
    private var with: UIImage? {
        get {
            guard let data = _withData else { return nil }
            return UIImage(data: data)
        }
        set {
            let data = newValue?.jpegData(compressionQuality: 1.0)
            _withData = data
        }
    }
    @objc dynamic private var _thumbnailImage: String? = nil
    var thumbnailImage: ThumbnailImage? {
        get {
            ThumbnailImage.fromPersistent(stringValue: _thumbnailImage, with: with)
        }
        set {
            (_thumbnailImage, with) = newValue?.toPersistent() ?? (nil, nil)
        }
    }
}
