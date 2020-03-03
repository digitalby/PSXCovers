//
//  DownloadsViewController.swift
//  PSXCovers
//
//  Created by Digital on 03/03/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

class DownloadsViewController: UIViewController {
    @IBOutlet var downloadsTableView: UITableView!
    @IBOutlet var noItemsView: NoItemsView!

    var game: Game? = nil

    var tableViewHelper: DownloadsTableViewHelper!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewHelper = DownloadsTableViewHelper(viewController: self)
        downloadsTableView.dataSource = tableViewHelper
        downloadsTableView.delegate = tableViewHelper
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadsTableView.reloadData()
    }
}

//MARK: - Segue
extension DownloadsViewController {
    func performShowGameSegue(with game: Game) {
        self.game = game
        performSegue(withIdentifier: "ShowGameFromDownload", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ShowGameFromDownload":
            guard
                let destinationViewController = segue.destination as? GameViewController,
                let senderViewController = sender as? DownloadsViewController,
                let game = senderViewController.game
                else { return }
            destinationViewController.game = game
            destinationViewController.presentedFromDownloads = true
        default:
            return
        }
    }
}
