//
//  IndexPath+Flatten.swift
//  PSXCovers
//
//  Created by Digital on 04/03/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

extension IndexPath {
    /// This method assumes the collection view is not empty and a valid index path was provided.
    static func flattenIndexPath(_ indexPath: IndexPath, for collectionView: UICollectionView) -> Int {
        var sum = 0
        for section in 0..<indexPath.section {
            sum += collectionView.numberOfItems(inSection: section)
        }
        sum += indexPath.row
        return sum
    }
}
