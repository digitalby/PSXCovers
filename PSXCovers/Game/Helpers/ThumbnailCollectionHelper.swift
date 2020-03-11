//
//  ThumbnailCollectionHelper.swift
//  PSXCovers
//
//  Created by Digital on 02/03/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

final class ThumbnailCollectionHelper: NSObject, ViewControllerHelper {
    weak var viewController: GameViewController? = nil
}

//MARK: - Data Source
extension ThumbnailCollectionHelper: UICollectionViewDataSource {
    var sectionedData: [[Cover]] { viewController?.game?.coversGroupedByCategory ?? [] }
    var sectionTitles: [String?] { viewController?.game?.sortedUniqueCoverCategories ?? [] }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = sectionTitles.count
        let noItems = count == 0
        viewController?.noItemsView?.isHidden = !noItems
        viewController?.rightBarButtonItem.isEnabled = !noItems
        return count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sectionedData[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CoverThumbnailCell",
            for: indexPath
            ) as? CoverThumbnailCell
            else { fatalError() }

        let section = indexPath.section
        let row = indexPath.row
        if (0..<sectionedData.count).contains(section),
            (0..<sectionedData[section].count).contains(row) {
            let cover = sectionedData[section][row]
            cell.label.text = cover.coverLabel
            CoverThumbnailCellConfigurator.configure(cell, with: cover)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: "CoverSectionHeader",
                    for: indexPath
                    ) as? CoverSectionHeader
                else { fatalError() }
            let section = indexPath.section
            if (0..<sectionTitles.count).contains(section) {
                header.label.text = sectionTitles[section]
            }
            return header
        default:
            assert(false)
        }
    }
}

//MARK: - Delegate
extension ThumbnailCollectionHelper: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let section = indexPath.section
        let row = indexPath.row
        guard (0..<sectionedData.count).contains(section), (0..<sectionedData[section].count).contains(row) else { return }
        let cover = sectionedData[section][row]
        viewController?.selectedIndexPath = indexPath
        if cover.thumbnailImageURL == nil && cover.fullSizeImageURL == nil {
            viewController?.present(
                UIAlertController.makeSimpleAlertWith(
                    title: "Error",
                    message: "Can't load cover."
                ),
                animated: true
            )
            return
        }
        viewController?.performSegue(withIdentifier: "PresentCover", sender: self)
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let item = collectionView.cellForItem(at: indexPath) as? CoverThumbnailCell else { return }
        UIView.animate(withDuration: 1/8) {
            item.highlightView.alpha = 0.5
        }
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let item = collectionView.cellForItem(at: indexPath) as? CoverThumbnailCell else { return }
        UIView.animate(withDuration: 1/8) {
            item.highlightView.alpha = 0.0
        }
    }
}

//MARK: - Flow Layout Delegate
extension ThumbnailCollectionHelper: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = collectionView.bounds
        let cellWidth = bounds.width / 2 - 16
        let cellHeight = bounds.height / 2 - 16
        let minimumDimension = min(cellWidth, cellHeight)
        let cellSize = min(minimumDimension, 238)
        return CGSize(width: cellSize, height: cellSize)
    }
}
