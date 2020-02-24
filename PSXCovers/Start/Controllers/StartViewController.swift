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
    func doFetch(urlString: String) {
        let alert = UIAlertController.makeWaitAlert()
        let tempDownloader = GameHTMLDownloader()
        present(alert, animated: true) { [unowned self] in
            tempDownloader.downloadGameHTML(urlString: urlString) { [unowned self] data, error in
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
        guard
            let urlString = gameURLSelectorView.gameURLField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            !urlString.isEmpty
        else { return }
        gameURLSelectorView.gameURLField.resignFirstResponder()
        goBarButtonItem.isEnabled = false
        doFetch(urlString: urlString)
    }
}
