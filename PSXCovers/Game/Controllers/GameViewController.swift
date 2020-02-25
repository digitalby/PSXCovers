//
//  GameViewController.swift
//  PSXCovers
//
//  Created by Digital on 25/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    var game: Game? = nil

    override func viewDidLoad() {
        title = game?.titleWithRegion
    }
}
