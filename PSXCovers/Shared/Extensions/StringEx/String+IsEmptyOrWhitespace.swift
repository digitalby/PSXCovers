//
//  String+IsEmptyOrWhitespace.swift
//  PSXCovers
//
//  Created by Digital on 24/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import Foundation

extension String {
    var isEmptyOrWhitespace: Bool {
        let trimmedText = trimmingCharacters(in: .whitespacesAndNewlines)
        let isEmpty = trimmedText.count == 0
        return isEmpty
    }
}
