//
//  ViewControllerHelper.swift
//  PSXCovers
//
//  Created by Digital on 04/03/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

protocol ViewControllerHelper: class {
    associatedtype T where T: UIViewController
    var viewController: T? { get set }
    init()
    init(viewController: T)
}

extension ViewControllerHelper {
    init(viewController: T) {
        self.init()
        self.viewController = viewController
    }
}
