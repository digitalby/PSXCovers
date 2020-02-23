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

//MARK: - Actions
extension StartViewController {
    @IBAction func didSelectGoBarButtonItem(_ sender: Any) {
        let alert = UIAlertController(title: "Go", message: "You selected Go!", preferredStyle: .alert)
        let buttonOk = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(buttonOk)
        present(alert, animated: true)
    }
}
