//
//  Game.swift
//  PSXCovers
//
//  Created by Digital on 25/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

struct Game {
    let title: String
    let region: Region?
    let covers: [Cover]
}

extension Game {
    var titleWithRegion: String {
        var title = self.title
        if
            !title.isEmptyOrWhitespace,
            let regionString = region?.stringValue {
            title += " (\(regionString))"
        }
        return title
    }
}
