//
//  GameURLSelectorViewDelegate.swift
//  PSXCovers
//
//  Created by Digital on 23/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

@objc protocol GameURLSelectorViewDelegate: class {
    func didSelectUseAnExample()
    func shouldReturnTextField() -> Bool
}
