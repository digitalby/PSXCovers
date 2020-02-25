//
//  Game.swift
//  PSXCovers
//
//  Created by Digital on 25/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import Foundation

struct Game {
    let url: URL
    let title: String
    let region: Region?
    let covers: [Cover]

    init(url: URL, title: String, region: Region? = nil, covers: [Cover] = []) {
        self.url = url
        self.title = title
        self.region = region
        self.covers = covers
    }
}

//MARK: - Title/Region Helpers
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

//MARK: - Covers Helpers
extension Game {
    var sortedUniqueCoverCategories: [String] {
        var coverCategories: [String] = []
        for category in covers.map({ $0.coverCategory }) {
            guard let category = category else { continue }
            coverCategories.append(category)
        }
        let uniqueCoverCategories = Set(coverCategories)
        return Array(uniqueCoverCategories).sorted()
    }

    var coversGroupedByCategory: [[Cover]] {
        (sortedUniqueCoverCategories + [nil]).map { category in
            let filteredCoverCategories = covers.filter { $0.coverCategory == category }
            return filteredCoverCategories.sorted {
                $0.coverCategory ?? "" < $1.coverCategory ?? ""
            }
        }
    }
}
