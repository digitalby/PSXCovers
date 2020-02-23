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
    private let exampleURL = "http://psxdatacenter.com/games/P/R/SCES-00001.html"

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
        let text = gameURLSelectorView.gameURLField.text
        let trimmedText = text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let isEmpty = trimmedText?.count ?? 0 == 0

        goBarButtonItem.isEnabled = !isEmpty
    }
}

//MARK: - Game URL Selector delegation
extension StartViewController: GameURLSelectorViewDelegate {
    func didSelectUseAnExample() {
        gameURLSelectorView.gameURLField.text = exampleURL
        updateEnabledStateForGoBarButtonItem()
    }
}

//MARK: - Network request
extension StartViewController {
    func makeWaitAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Please wait, working...", message: nil, preferredStyle: .alert)
        let throbber = UIActivityIndicatorView(style: .medium)
        throbber.startAnimating()
        throbber.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(throbber)
        NSLayoutConstraint.activate([
            throbber.centerYAnchor.constraint(equalTo: alert.view.centerYAnchor),
            throbber.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 16.0)
        ])
        return alert
    }

    func makeRequest(urlString: String) {
        let alert = makeWaitAlert()
        present(alert, animated: true) { [unowned self] in
            print("Request started!")
            self.requestCompleted(waitAlert: alert)
        }
    }

    func requestCompleted(waitAlert: UIAlertController) {
        waitAlert.dismiss(animated: true) { [unowned self] in
            let alert = UIAlertController(title: "Done", message: "Request completed!", preferredStyle: .alert)
            let buttonOk = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(buttonOk)
            self.present(alert, animated: true)
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
        makeRequest(urlString: urlString)
    }
}
