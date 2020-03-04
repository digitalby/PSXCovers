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
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = DataService.shared.data.count
        viewController?.noItemsView?.isHidden = count != 0
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as? FavoriteCell else { fatalError() }
        let data = DataService.shared.data
        let row = indexPath.row
        if (0..<data.count).contains(row) {
            let game = data[row]
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
}

//MARK: - Delegate
extension FavoritesTableViewHelper {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let viewController = viewController else { return }
        let row = indexPath.row
        let data = DataService.shared.data
        guard (0..<data.count).contains(row) else { return }
        let game = data[row]
        viewController.performShowGameSegue(with: game)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        do {
            let game = DataService.shared.data[indexPath.row]
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
