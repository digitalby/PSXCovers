//
//  CoverImageDownloadError.swift
//  PSXCovers
//
//  Created by Digital on 02/03/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import Foundation

enum CoverImageDownloadError: Error {
    case requestAlreadyPresent
    case coverIsMissing
    case responseError(Error)
    case dataError
}
