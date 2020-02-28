//
//  GameHTMLDownloader.swift
//  PSXCovers
//
//  Created by Digital on 24/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import Foundation
import Alamofire

class GameHTMLDownloader {

    static let session = Session()

    func downloadGameHTML(at url: URL, completion: @escaping (String?, Error?) -> Void) {
        GameHTMLDownloader.session.request(url).validate().responseString { string in
            if let error = string.error {
                completion(nil, error)
                return
            }
            guard let data = string.value else {
                let error = AFError.responseSerializationFailed(reason: .stringSerializationFailed(encoding: .isoLatin1))
                completion(nil, error)
                return
            }
            completion(data, nil)
        }
    }
}
