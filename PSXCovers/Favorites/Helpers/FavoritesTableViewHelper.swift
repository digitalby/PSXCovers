//
//  FavoritesTableViewHelper.swift
//  PSXCovers
//
//  Created by Digital on 03/03/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

final class FavoritesTableViewHelper: NSObject, ViewControllerHelper, UITableViewDataSource, UITableViewDelegate {
    weak var viewController: FavoritesViewController? = nil
}

//MARK: - Data Source
extension FavoritesTableViewHelper {
    var sectionedData: [[Game]] { DataService.shared.sectionedData }
    var firstLetters: [String] { DataService.shared.uniqueFirstLetters }

    func numberOfSections(in tableView: UITableView) -> Int {
        let count = sectionedData.count
        viewController?.noItemsView?.isHidden = count != 0
        return count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sectionedData[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as? FavoriteCell else { fatalError() }

        let section = indexPath.section
        let row = indexPath.row
        if (0..<sectionedData.count).contains(section),
            (0..<sectionedData[section].count).contains(row) {
            let game = sectionedData[section][row]
            cell.titleLabel.text = game.titleWithRegion
            if case let .with(image) = game.mainThumbnail {
                cell.thumbnailImageView?.image = image
            } else if game.mainThumbnailURL != nil {
                cell.thumbnailImageView?.image = ImageConstants.placeholderLoading
            } else {
                cell.thumbnailImageView?.image = ImageConstants.placeholderError
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        firstLetters[section]
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        firstLetters
    }
}

//MARK: - Delegate
extension FavoritesTableViewHelper {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let viewController = viewController else { return }
        let section = indexPath.section
        let row = indexPath.row
        guard (0..<sectionedData.count).contains(section), (0..<sectionedData[section].count).contains(row) else { return }
        let game = sectionedData[section][row]
        viewController.performShowGameSegue(with: game)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let section = indexPath.section
        let row = indexPath.row
        guard (0..<sectionedData.count).contains(section), (0..<sectionedData[section].count).contains(row) else { return }
        let game = sectionedData[section][row]
        do {
            try DataService.shared.delete(game: game)
            tableView.deleteRows(at: [indexPath], with: .left)
        } catch {
            viewController?.present(
                UIAlertController.makeSimpleAlertWith(
                    title: "Error",
                    message: "Failed to delete item."
                ),
                animated: true
            )
        }
    }
}
