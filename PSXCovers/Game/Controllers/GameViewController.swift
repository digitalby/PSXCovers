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

    let coverThumbnailDownloader = CoverThumbnailDownloader()

    var presentedFromDownloads = false
    var game: Game!
    var selectedIndexPath: IndexPath? = nil
    let destinationDismissTransition = DismissTransitionInteractor()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = thumbnailCollectionHelper
        collectionView.delegate = thumbnailCollectionHelper
        updateAddButtonState()
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

//MARK: - Download helper
extension GameViewController {
    func updateAddButtonState() {
        let data = DataService.shared.data
        if data.contains(where: { $0.titleWithRegion == game.titleWithRegion }) {
            rightBarButtonItem.image = UIImage(systemName: "square.and.arrow.down.fill")
        } else {
            rightBarButtonItem.image = UIImage(systemName: "square.and.arrow.down")
        }
    }
}

//MARK: - Actions
extension GameViewController {
    @IBAction func didTapAdd(_ sender: Any) {
        guard let game = game else { return }
        let data = DataService.shared.data
        if data.contains(where: { $0.titleWithRegion == game.titleWithRegion }) {
            let alert = UIAlertController(title: "Delete download", message: "Do you wish to delete this game from your Downloads?", preferredStyle: .alert)
            let buttonDelete = UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                guard let game = self?.game else { return }
                DataService.shared.data.removeAll { $0.titleWithRegion == game.titleWithRegion }
                self?.updateAddButtonState()
                if self?.presentedFromDownloads == true {
                    self?.navigationController?.popViewController(animated: true)
                }
            })
            let buttonCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert.addAction(buttonDelete)
            alert.addAction(buttonCancel)
            present(alert, animated: true)
        } else {
            DataService.shared.data.append(game)
        }
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
