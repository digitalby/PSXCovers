//
//  GameViewController.swift
//  PSXCovers
//
//  Created by Digital on 25/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var noItemsView: NoItemsView!

    var game: Game? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        noItemsView.mainLabel.text = "There are no covers."
        title = game?.titleWithRegion ?? ""
    }
}

//MARK: - Data Source
extension GameViewController: UICollectionViewDataSource {
    var sectionedData: [[Cover]] { game?.coversGroupedByCategory ?? [[]] }
    var sectionTitles: [String?] { game?.sortedUniqueCoverCategories ?? [] }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = sectionTitles.count
        if count == 0 {
            noItemsView?.isHidden = false
        } else {
            noItemsView?.isHidden = true
        }
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

        cell.thumbnailImageView.image = UIImage(named: "placeholder_loading")
        let section = indexPath.section
        let row = indexPath.row
        if (0..<sectionedData.count).contains(section),
            (0..<sectionedData[section].count).contains(row) {
            cell.label.text = sectionedData[section][row].coverLabel
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
extension GameViewController: UICollectionViewDelegate {

}
