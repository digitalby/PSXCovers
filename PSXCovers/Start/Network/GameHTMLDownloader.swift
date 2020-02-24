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
    func downloadGameHTML(at url: URL, completion: @escaping (String?, Error?) -> Void) {
        Alamofire.request(url).validate().responseString { responseString in
            if let error = responseString.result.error {
                completion(nil, error)
                return
            }
            guard let data = responseString.result.value else {
                let error = AFError.responseSerializationFailed(reason: .stringSerializationFailed(encoding: .isoLatin1))
                completion(nil, error)
                return
            }
            completion(data, nil)
        }
    }
}
