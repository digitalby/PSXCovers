//
//  GameViewController.swift
//  PSXCovers
//
//  Created by Digital on 25/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit
import RealmSwift

class GameViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var noItemsView: NoItemsView!
    @IBOutlet var rightBarButtonItem: UIBarButtonItem!

    lazy var thumbnailCollectionHelper = ThumbnailCollectionHelper(viewController: self)

    let coverThumbnailDownloader = CoverThumbnailDownloader()

    let realm = try! Realm()
    var game: Game!
    var selectedIndexPath: IndexPath? = nil
    let destinationDismissTransition = DismissTransitionInteractor()

    var isFavorite = false
    var presentedFromFavorites = false

    override func viewDidLoad() {
        super.viewDidLoad()

        title = game.titleWithRegion

        isFavorite = DataService.shared.data.filter("(title=%@) AND (_region=%@)", game.title ?? "", game.region?.rawValue ?? "").count == 1
        updateAddButtonState()

        collectionView.dataSource = thumbnailCollectionHelper
        collectionView.delegate = thumbnailCollectionHelper
        if game.mainThumbnail == nil {
            if let mainThumbnailURL = game.mainThumbnailURL {
                coverThumbnailDownloader.downloadThumbnail(at: mainThumbnailURL) { [weak self] thumbnailImage in
                    guard case .with(_) = thumbnailImage else { return }
                    self?.game.mainThumbnail = thumbnailImage
                }
            }
        }
        game.covers
            .filter { $0.thumbnailImage == nil }
            .forEach { cover in
            coverThumbnailDownloader.downloadThumbnail(for: cover) { [weak self] image in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    cover.thumbnailImage = image
                    self.collectionView.reloadData()
                }
            }
        }
    }

    override var hidesBottomBarWhenPushed: Bool {
        get { true }
        set { self.hidesBottomBarWhenPushed = newValue }
    }

    override var prefersStatusBarHidden: Bool { false }

    override func viewWillDisappear(_ animated: Bool) {
        self.commitFavoriteToRealm()
        if self.presentedFromFavorites {
            let favorites = self.navigationController?.viewControllers.first as? FavoritesViewController
            favorites?.favoritesTableView.reloadData()
        }
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        type(of: coverThumbnailDownloader).session.cancelAllRequests() {
            super.viewDidDisappear(animated)
        }
    }
}

//MARK: - Favorite helper
extension GameViewController {
    func updateAddButtonState() {
        if isFavorite {
            rightBarButtonItem.image = UIImage(systemName: "star.fill")
        } else {
            rightBarButtonItem.image = UIImage(systemName: "star")
        }
    }

    func commitFavoriteToRealm() {
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
                let alert = UIAlertController(title: "Error", message: "Failed to add favorite.", preferredStyle: .alert)
                let buttonOk = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(buttonOk)
                present(alert, animated: true)
            }
        } else {
            do {
                guard results.count == 1 else { return }
                try DataService.realm.write {
                    DataService.realm.delete(results)
                }
            } catch {
                let alert = UIAlertController(title: "Error", message: "Failed to delete favorite.", preferredStyle: .alert)
                let buttonOk = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(buttonOk)
                present(alert, animated: true)
            }
        }
    }
}

//MARK: - Actions
extension GameViewController {
    @IBAction func didTapAdd(_ sender: Any) {
        isFavorite.toggle()
        updateAddButtonState()
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
            destination.transitioningDelegate = destination
            destination.dismissTransition = destinationDismissTransition
            destination.modalPresentationCapturesStatusBarAppearance = true
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
