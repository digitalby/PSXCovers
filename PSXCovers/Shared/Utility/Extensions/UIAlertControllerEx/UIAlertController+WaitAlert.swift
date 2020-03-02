//
//  UIAlertController+WaitAlert.swift
//  PSXCovers
//
//  Created by Digital on 24/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

extension UIAlertController {
    class func makeWaitAlert(onCancel: (() -> Void)?) -> Self {
        let alert = Self(title: "Please wait, working...", message: nil, preferredStyle: .alert)
//FIXME: Throbber omitted because its placement has issues with Dynamic Type.
//        let throbber = UIActivityIndicatorView(style: .medium)
//        throbber.startAnimating()
//        throbber.translatesAutoresizingMaskIntoConstraints = false
//        alert.view.addSubview(throbber)
//        NSLayoutConstraint.activate([
//            throbber.centerYAnchor.constraint(equalTo: alert.view.centerYAnchor),
//            throbber.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 16.0)
//        ])
        if let onCancel = onCancel {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                let action = UIAlertAction(title: "Cancel", style: .destructive) { _ in
                    onCancel()
                }
                alert.addAction(action)
            }
        }
        return alert
    }
}
