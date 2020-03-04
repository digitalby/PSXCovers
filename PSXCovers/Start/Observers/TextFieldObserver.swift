//
//  TextFieldObserver.swift
//  PSXCovers
//
//  Created by Digital on 27/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

class TextFieldObserver {

    let callback: VoidCallback
    let textField: UITextField

    init(textField: UITextField, textDidChangeCallback: @escaping VoidCallback) {
        self.textField = textField
        callback = textDidChangeCallback
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange),
            name: UITextField.textDidChangeNotification,
            object: textField
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: UITextField.textDidChangeNotification,
            object: textField
        )
    }
}

//MARK: - Selectors
private extension TextFieldObserver {
    @objc func textDidChange(_ notification: Notification) {
        callback()
    }
}
