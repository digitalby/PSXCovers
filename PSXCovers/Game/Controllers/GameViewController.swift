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

    lazy var thumbnailCollectionHelper = ThumbnailCollectionHelper(viewController: self)

    let coverThumbnailDownloader = CoverThumbnailDownloader()

    var game: Game!
    var selectedIndexPath: IndexPath? = nil
    let destinationDismissTransition = DismissTransitionInteractor()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = thumbnailCollectionHelper
        collectionView.delegate = thumbnailCollectionHelper
        title = game.titleWithRegion
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

    override func viewDidDisappear(_ animated: Bool) {
        type(of: coverThumbnailDownloader).session.cancelAllRequests() {
            super.viewDidDisappear(animated)
        }
    }
}

//MARK: - Actions
extension GameViewController {
    @IBAction func didTapAdd(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "You tapped add", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
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
