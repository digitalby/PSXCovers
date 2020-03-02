//
//  GameURLPasteboardListener.swift
//  PSXCovers
//
//  Created by Digital on 02/03/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

class GameURLPasteboardListener {
    weak var viewController: UIViewController? = nil
    var ignoreString: String? = nil
    fileprivate(set) var lastValidPasteboardString: String? = nil

    var pasteCallback: URLCallback? = nil
    var pasteAndGoCallback: URLCallback? = nil
    fileprivate var pasteboardObserver: PasteboardObserver!
    fileprivate var appActivityObserver: AppActivityObserver!

    init(viewController: UIViewController, pasteCallback: URLCallback? = nil, pasteAndGoCallback: URLCallback? = nil) {
        self.viewController = viewController
        self.pasteCallback = pasteCallback
        self.pasteAndGoCallback = pasteAndGoCallback
        pasteboardObserver = PasteboardObserver(changedCallback: checkPasteboard)
        appActivityObserver = AppActivityObserver(becameActiveCallback: checkPasteboard)
        checkPasteboard()
    }

    fileprivate func pasteFromPasteboardIfNeeded(pasteboardString: String) {
        do {
            let url = try GameURLValidator().makeValidatedPSXGameURL(urlString: pasteboardString)
            let alert = UIAlertController(title: nil, message: "Do you wish to use the link from your clipboard?", preferredStyle: .alert)
            let buttonPasteAndGo = UIAlertAction(title: "Paste & Go", style: .default) { [unowned self] _ in
                self.pasteAndGoCallback?(url)
            }
            alert.addAction(buttonPasteAndGo)
            let buttonPaste = UIAlertAction(title: "Paste", style: .default) { [unowned self] _ in
                self.pasteCallback?(url)
            }
            alert.addAction(buttonPaste)
            let buttonCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(buttonCancel)
            viewController?.present(alert, animated: true)
        } catch { return }
    }

    func checkPasteboard() {
        guard
            let pasteboardString = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines)
            else { return }
        //let textFieldString = gameURLSelectorView.gameURLField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedIgnoreString = ignoreString?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            lastValidPasteboardString != pasteboardString,
            trimmedIgnoreString?.range(of: pasteboardString) == nil
        else { return }
        lastValidPasteboardString = pasteboardString
        guard viewController?.navigationController?.topViewController == viewController else { return }
        pasteFromPasteboardIfNeeded(pasteboardString: pasteboardString)
    }
}
