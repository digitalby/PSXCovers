//
//  DataService.swift
//  PSXCovers
//
//  Created by Digital on 03/03/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import UIKit
import RealmSwift

class DataService {
    static let shared = DataService()
    static let realm = try! Realm()

    lazy var data: Results<Game> = {
        type(of: self).realm.objects(Game.self)
    }()
}
