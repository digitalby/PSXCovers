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
    func doFetch(at psxGameURL: URL) {
        let alert = UIAlertController.makeWaitAlert()
        let tempDownloader = GameHTMLDownloader()
        present(alert, animated: true) { [unowned self] in
            tempDownloader.downloadGameHTML(at: psxGameURL) { [unowned self] data, error in
                if let error = error {
                    print(error)
                } else if let data = data {
                    print(data)
                }
                alert.dismiss(animated: true)
                self.updateEnabledStateForGoBarButtonItem()
            }
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
            doFetch(at: psxGameURL)
        } catch let error as GameURLValidationError {
            var message: String? = nil
            switch error {
            case .invalidURLString, .urlInitializationFailed, .urlComponentsInitializationFailed:
                message = "You've provided an invalid link."
            case .hostIsNotPSXDC:
                message = "The link that you've provided is not a psxdatacenter.com link."
            case .invalidPlatformSubpath:
                message = "The link that you've provided is not for a PSX game."
                    + "Please check your link, or try a different PSX game link."
            case .invalidRegionSubpath, .invalidAlphabetGroupSubpath, .invalidPSXGameSubpath:
                message = "The link that you've provided is not a valid PSX game link."
                    + "Please check your link and try again."
            }
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let buttonOk = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(buttonOk)
            present(alert, animated: true)
        } catch { return }
    }
}
