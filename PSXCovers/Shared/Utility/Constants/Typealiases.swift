//
//  Typealiases.swift
//  PSXCovers
//
//  Created by Digital on 02/03/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

typealias UIImageDownloadCompletion = (UIImage?, Error?)->()
typealias HTMLDownloadCompletion = (String?, Error?) -> Void
typealias URLCallback = (URL)->(Void)
