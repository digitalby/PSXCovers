//
//  GameFavoriteHelper.swift
//  PSXCovers
//
//  Created by Digital on 04/03/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

final class GameFavoriteHelper: ViewControllerHelper {
    weak var viewController: GameViewController? = nil

    var isFavorite = false
    var presentedFromFavorites = false

    func setup() {
        guard let game = viewController?.game else { return }
        isFavorite = DataService.shared.isGameFavorite(game)
        updateAddButtonState()
    }
}

extension GameFavoriteHelper {
    func updateAddButtonState() {
        guard let viewController = viewController else { return }
        if isFavorite {
            viewController.rightBarButtonItem.image = UIImage(systemName: "star.fill")
        } else {
            viewController.rightBarButtonItem.image = UIImage(systemName: "star")
        }
    }

    func commitFavoriteToRealm() {
        guard
            let viewController = viewController,
            let game = viewController.game
            else { return }
        if isFavorite {
            do {
                try DataService.shared.add(game: game)
            } catch {
                viewController.present(
                    UIAlertController.makeSimpleAlertWith(
                        title: "Error",
                        message: "Failed to add favorite."
                    ), animated: true
                )
            }
        } else {
            do {
                try DataService.shared.delete(game: game)
            } catch {
                viewController.present(
                    UIAlertController.makeSimpleAlertWith(
                        title: "Error",
                        message: "Failed to delete favorite."
                    ), animated: true
                )
            }
        }
    }

    func updateFavoritesViewControllerIfNeeded() {
        if presentedFromFavorites {
            let favorites = viewController?.navigationController?.viewControllers.first as? FavoritesViewController
            favorites?.favoritesTableView.reloadData()
        }
    }
}
