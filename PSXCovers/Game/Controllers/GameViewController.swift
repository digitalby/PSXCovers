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
    @IBOutlet var rightBarButtonItem: UIBarButtonItem!

    lazy var thumbnailCollectionHelper = ThumbnailCollectionHelper(viewController: self)
    lazy var gameFavoriteHelper = GameFavoriteHelper(viewController: self)

    let coverThumbnailDownloader = CoverThumbnailDownloader()

    var game: Game!

    var selectedIndexPath: IndexPath? = nil
    let destinationDismissTransition = DismissTransitionInteractor()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = game.titleWithRegion
        gameFavoriteHelper.setup()

        collectionView.dataSource = thumbnailCollectionHelper
        collectionView.delegate = thumbnailCollectionHelper
        if game.mainThumbnail == nil {
            if let mainThumbnailURL = game.mainThumbnailURL {
                coverThumbnailDownloader.downloadThumbnail(at: mainThumbnailURL) { [weak self] thumbnailImage in
                    guard let self = self, case .with(_) = thumbnailImage else { return }
                    DataService.shared.performSafeWriteOperation(for: self.game) {
                        self.game.mainThumbnail = thumbnailImage
                    }
                }
            }
        }
        game.covers
            .filter { $0.thumbnailImage == nil }
            .forEach { cover in
            coverThumbnailDownloader.downloadThumbnail(for: cover) { [weak self] image in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    DataService.shared.performSafeWriteOperation(for: self.game) {
                        cover.thumbnailImage = image
                    }
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
//        gameFavoriteHelper.commitFavoriteToRealm()
        gameFavoriteHelper.updateFavoritesViewControllerIfNeeded()
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        type(of: coverThumbnailDownloader).session.cancelAllRequests() {
            super.viewDidDisappear(animated)
        }
    }
}

//MARK: - Actions
extension GameViewController {
    @IBAction func didTapAdd(_ sender: Any) {
        gameFavoriteHelper.isFavorite.toggle()
        gameFavoriteHelper.commitFavoriteToRealm()
        gameFavoriteHelper.updateAddButtonState()
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
            let coverIndex = IndexPath.flattenIndexPath(indexPath, for: collectionView)
            destination.game = game
            destination.initialCoverIndex = coverIndex
            destination.transitioningDelegate = destination
            destination.dismissTransition = destinationDismissTransition
            destination.modalPresentationCapturesStatusBarAppearance = true
        default:
            return
        }
    }
}
