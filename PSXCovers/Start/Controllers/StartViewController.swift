//
//  StartViewController.swift
//  PSXCovers
//
//  Created by Digital on 23/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    @IBOutlet var gameURLSelectorView: GameURLSelectionView!
    @IBOutlet var goBarButtonItem: UIBarButtonItem!
    @IBOutlet var gameURLSelectorViewBottomConstraint: NSLayoutConstraint!

    private var keyboardConstraintObserver: KeyboardConstraintObserver!
    private var textFieldObserver: TextFieldObserver!
    private var pasteboardListener: GameURLPasteboardListener!

    private let exampleURLString = "http://psxdatacenter.com/games/P/R/SCES-00001.html"

    private var game: Game? = nil
    let gameHTMLDownloader = GameHTMLDownloader()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateEnabledStateForGoBarButtonItem()
        textFieldObserver = TextFieldObserver(
            textField: gameURLSelectorView.gameURLField,
            textDidChangeCallback: updateEnabledStateForGoBarButtonItem
        )
        keyboardConstraintObserver = KeyboardConstraintObserver(
            bottomConstraint: gameURLSelectorViewBottomConstraint,
            viewToAdjust: gameURLSelectorView
        )
        pasteboardListener = GameURLPasteboardListener(
            viewController: self,
            pasteCallback: { [unowned self] url in
                self.gameURLSelectorView.gameURLField.text = url.absoluteString
                self.updateEnabledStateForGoBarButtonItem()
            },
            pasteAndGoCallback: { [unowned self] url in
                self.gameURLSelectorView.gameURLField.text = url.absoluteString
                self.downloadGame(at: url)
            }
        )
    }

    override var prefersStatusBarHidden: Bool { false }
}

//MARK: - Text Field check
extension StartViewController {
    func updateEnabledStateForGoBarButtonItem() {
        let isEmpty = gameURLSelectorView.gameURLField.text?.isEmptyOrWhitespace
        goBarButtonItem.isEnabled = isEmpty == false
    }
}

//MARK: - Game URL Selector delegation
extension StartViewController: GameURLSelectorViewDelegate {
    func shouldReturnTextField() -> Bool {
        prepareToDownloadGame()
        return true
    }

    func didSelectUseAnExample() {
        gameURLSelectorView.gameURLField.text = exampleURLString
        updateEnabledStateForGoBarButtonItem()
    }
}

//MARK: - Network request
extension StartViewController {
    func prepareToDownloadGame() {
        gameURLSelectorView.gameURLField.resignFirstResponder()
        guard let urlString = gameURLSelectorView.gameURLField.text, !urlString.isEmptyOrWhitespace else {
            updateEnabledStateForGoBarButtonItem()
            return
        }
        do {
            let psxGameURL = try GameURLValidator().makeValidatedPSXGameURL(urlString: urlString)
            let downloads = DataService.shared.gamesWith(url: psxGameURL)
            if downloads.count == 1, let game = downloads.first {
                self.game = game
                performSegue(withIdentifier: "ShowGameFromURL", sender: self)
            } else {
                downloadGame(at: psxGameURL)
            }
        } catch let error as GameURLValidationError {
            let alert = ValidationErrorHandler().makeAlertController(for: error)
            present(alert, animated: true)
        } catch { return }
    }

    func downloadGame(at psxGameURL: URL) {
        goBarButtonItem.isEnabled = false
        let waitAlert = UIAlertController.makeWaitAlert(onCancel: {
            GameHTMLDownloader.session.cancelAllRequests()
        })
        present(waitAlert, animated: true) { [unowned self] in
            self.gameHTMLDownloader.downloadGameHTML(at: psxGameURL) { [unowned self] data, error in
                if let error = error {
                    waitAlert.dismiss(animated: true) { [unowned self] in
                        guard let alert = NetworkErrorHandler().makeAlertController(for: error) else { return }
                        self.present(alert, animated: true)
                    }
                } else if let data = data {
                    waitAlert.dismiss(animated: true) { [unowned self] in
                        self.parseGame(url: psxGameURL, html: data)
                    }
                }
                waitAlert.dismiss(animated: true) { [unowned self] in
                    self.updateEnabledStateForGoBarButtonItem()
                }
            }
        }
    }

    func parseGame(url: URL, html: String) {
        game = GameHTMLParser(gameURL: url).makeGame(fromHTML: html)
        performSegue(withIdentifier: "ShowGameFromURL", sender: self)
    }
}

//MARK: - Segues
extension StartViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ShowGameFromURL":
            guard
                let destinationViewController = segue.destination as? GameViewController,
                let senderViewController = sender as? StartViewController,
                let game = senderViewController.game
                else { return }
            destinationViewController.game = game

        default:
            return
        }
    }
}

//MARK: - Actions
extension StartViewController {
    @IBAction func didSelectGoBarButtonItem(_ sender: Any) {
        prepareToDownloadGame()
    }
}
