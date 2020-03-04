//
//  AppActivityObserver.swift
//  PSXCovers
//
//  Created by Digital on 27/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

class AppActivityObserver {

    let didBecomeActiveCallback: VoidCallback?

    init(didBecomeActiveCallback: VoidCallback? = nil) {
        self.didBecomeActiveCallback = didBecomeActiveCallback
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
}

//MARK: - Selectors
private extension AppActivityObserver {
    @objc func didBecomeActive(_ notification: Notification) {
        didBecomeActiveCallback?()
    }
}
