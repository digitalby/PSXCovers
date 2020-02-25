//
//  StartViewController.swift
//  PSXCovers
//
//  Created by Digital on 23/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    @IBOutlet var gameURLSelectorView: GameURLSelectorView!
    @IBOutlet var goBarButtonItem: UIBarButtonItem!
    @IBOutlet var gameURLSelectorViewBottomConstraint: NSLayoutConstraint!

    private var keyboardConstraintAdjuster: KeyboardConstraintAdjuster!
    private let exampleURLString = "http://psxdatacenter.com/games/P/R/SCES-00001.html"

    private var game: Game? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        gameURLSelectorView.delegate = self
        NotificationCenter.default.addObserver(
            forName: UITextField.textDidChangeNotification,
            object: gameURLSelectorView.gameURLField,
            queue: OperationQueue.main
        ) { [unowned self] _ in
            self.updateEnabledStateForGoBarButtonItem()
        }
        updateEnabledStateForGoBarButtonItem()
        keyboardConstraintAdjuster = KeyboardConstraintAdjuster(
            bottomConstraint: gameURLSelectorViewBottomConstraint,
            viewToAdjust: gameURLSelectorView
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: UITextField.textDidChangeNotification,
            object: gameURLSelectorView.gameURLField)
    }
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
    func didSelectUseAnExample() {
        gameURLSelectorView.gameURLField.text = exampleURLString
        updateEnabledStateForGoBarButtonItem()
    }
}

//MARK: - Network request
extension StartViewController {
    func downloadGame(at psxGameURL: URL) {
        let waitAlert = UIAlertController.makeWaitAlert()
        present(waitAlert, animated: true) { [unowned self] in
            GameHTMLDownloader().downloadGameHTML(at: psxGameURL) { [unowned self] data, error in
                if let error = error {
                    waitAlert.dismiss(animated: true) { [unowned self] in
                        let alert = NetworkErrorHandler().makeAlertController(for: error)
                        self.present(alert, animated: true)
                    }
                } else if let data = data {
                    self.parseGame(url: psxGameURL, html: data)
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
        guard let urlString = gameURLSelectorView.gameURLField.text else {
            updateEnabledStateForGoBarButtonItem()
            return
        }
        gameURLSelectorView.gameURLField.resignFirstResponder()
        do {
            let psxGameURL = try GameURLValidator().makeValidatedPSXGameURL(urlString: urlString)
            goBarButtonItem.isEnabled = false
            downloadGame(at: psxGameURL)
        } catch let error as GameURLValidationError {
            let alert = ValidationErrorHandler().makeAlertController(for: error)
            present(alert, animated: true)
        } catch { return }
    }
}
