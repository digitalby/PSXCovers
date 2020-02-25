//
//  GameViewController.swift
//  PSXCovers
//
//  Created by Digital on 25/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

class GameViewController: UICollectionViewController {
    var game: Game? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let game = game else { return }
        title = game.titleWithRegion
        print("\(game.titleWithRegion) has \(game.covers.count) cover(s):")
        dump(game.covers)
        print([String](repeating: "-", count: 12).joined())
        #warning("WIP: Section titles are not displayed.")
        dump(sectionTitles)
    }
}

//MARK: - Data Source
extension GameViewController {
    var sectionedData: [[Cover]] { game?.coversGroupedByCategory ?? [[]] }
    var sectionTitles: [String] { game?.sortedUniqueCoverCategories ?? [] }

    override func indexTitles(for collectionView: UICollectionView) -> [String]? {
        sectionTitles
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        sectionedData.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sectionedData[section].count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: "CoverThumbnailCell", for: indexPath)
    }
}

//MARK: - Delegate
extension GameViewController {

}
