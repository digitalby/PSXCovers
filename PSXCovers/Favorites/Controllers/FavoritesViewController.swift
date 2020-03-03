//
//  FavoritesViewController.swift
//  PSXCovers
//
//  Created by Digital on 03/03/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {
    @IBOutlet var favoritesTableView: UITableView!
    @IBOutlet var noItemsView: NoItemsView!

    var game: Game? = nil

    var tableViewHelper: FavoritesTableViewHelper!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewHelper = FavoritesTableViewHelper(viewController: self)
        favoritesTableView.dataSource = tableViewHelper
        favoritesTableView.delegate = tableViewHelper
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        favoritesTableView.reloadData()
    }
}

//MARK: - Segue
extension FavoritesViewController {
    func performShowGameSegue(with game: Game) {
        self.game = game
        performSegue(withIdentifier: "ShowGameFromFavorite", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ShowGameFromFavorite":
            guard
                let destinationViewController = segue.destination as? GameViewController,
                let senderViewController = sender as? FavoritesViewController,
                let game = senderViewController.game
                else { return }
            destinationViewController.game = game
            destinationViewController.presentedFromFavorites = true
        default:
            return
        }
    }
}
