//
//  UIAlertController+SimpleAlert.swift
//  PSXCovers
//
//  Created by Digital on 04/03/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

extension UIAlertController {
    class func makeSimpleAlertWith(title: String?, message: String?) -> Self {
        let alert = Self(title: title, message: message, preferredStyle: .alert)
        let buttonOk = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(buttonOk)
        return alert
    }
}
