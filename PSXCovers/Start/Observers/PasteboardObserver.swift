//
//  PasteboardObserver.swift
//  PSXCovers
//
//  Created by Digital on 27/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

class PasteboardObserver {

    let callback: () -> ()

    init(changedCallback: @escaping () -> ()) {
        self.callback = changedCallback
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(pasteboardChanged),
            name: UIPasteboard.changedNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: UIPasteboard.changedNotification,
            object: nil
        )
    }
}

//MARK: - Selectors
private extension PasteboardObserver {
    @objc func pasteboardChanged(_ notification: Notification) {
        callback()
    }
}
