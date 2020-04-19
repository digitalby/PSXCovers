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

    func downloadGameHTML(at url: URL, completion: HTMLDownloadCallback? = nil) {
        GameHTMLDownloader.session.request(url).validate().responseString { responseString in
            if let error = responseString.error {
                completion?(nil, error)
                return
            }
            guard let data = responseString.data else {
                let error = AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
                completion?(nil, error)
                return
            }
            let string = data.starts(with: [0xff, 0xfe]) ?
                String(bytes: data, encoding: .utf16) :
                responseString.value
            if let string = string {
                completion?(string, nil)
            } else {
                let error = AFError.responseSerializationFailed(reason: .stringSerializationFailed(encoding: .utf8))
                completion?(nil, error)
            }
        }
    }
}
