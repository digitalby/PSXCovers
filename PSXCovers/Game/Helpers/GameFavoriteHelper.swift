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
        isFavorite = DataService.shared.data.filter(
            "(title=%@) AND (_region=%@)",
            game.title ?? "",
            game.region?.rawValue ?? "")
            .count == 1
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
        let title = game.title ?? ""
        let region = game.region?.rawValue ?? ""
        let results = DataService.shared.data.filter("(title=%@) AND (_region=%@)", title, region)
        if isFavorite {
            do {
                guard results.count == 0 else { return }
                try DataService.realm.write {
                    DataService.realm.add(game)
                }
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
                guard results.count == 1 else { return }
                try DataService.realm.write {
                    DataService.realm.delete(results)
                }
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
}
