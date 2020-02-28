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

    let coverThumbnailDownloader = CoverThumbnailDownloader()

    var game: Game? = nil

    var selectedIndexPath: IndexPath? = nil

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

        cell.thumbnailImageView.image = nil
        let section = indexPath.section
        let row = indexPath.row
        if (0..<sectionedData.count).contains(section),
            (0..<sectionedData[section].count).contains(row) {
            let cover = sectionedData[section][row]
            cell.label.text = cover.coverLabel
            if cover.thumbnailImageURL != nil {
                cell.thumbnailImageView.image = UIImage(named: "placeholder_loading")
                coverThumbnailDownloader.downloadThumbnail(for: cover) { image in
                    cell.thumbnailImageView.image = image ?? UIImage(named: "placeholder_error")
                }
            } else {
                cell.thumbnailImageView.image = UIImage(named: "placeholder_error")
            }
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let section = indexPath.section
        let row = indexPath.row
        guard (0..<sectionedData.count).contains(section), (0..<sectionedData[section].count).contains(row) else { return }
        let cover = sectionedData[section][row]
        selectedIndexPath = indexPath
        if cover.thumbnailImageURL == nil && cover.fullSizeImageURL == nil {
            let alert = UIAlertController(title: "Error", message: "Can't load cover.", preferredStyle: .alert)
            let buttonOk = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(buttonOk)
            present(alert, animated: true)
            return
        }
        performSegue(withIdentifier: "PresentCover", sender: self)
    }
}

//MARK: - Segue
extension GameViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "PresentCover":
            guard
                let destination = segue.destination as? CoversPageViewController,
                let indexPath = selectedIndexPath
                else { return }
            let coverIndex = flattenIndexPath(indexPath)
            destination.game = game
            destination.initialCoverIndex = coverIndex
        default:
            return
        }
    }

    /// This method assumes the collection view is not empty and a valid index path was provided.
    private func flattenIndexPath(_ indexPath: IndexPath) -> Int {
        var sum = 0
        for section in 0..<indexPath.section {
            sum += collectionView.numberOfItems(inSection: section)
        }
        sum += indexPath.row
        return sum
    }
}
