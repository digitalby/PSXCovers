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
    let mainThumbnailURL: URL?
    var mainThumbnail: ThumbnailImage?
    let covers: [Cover]

    init(url: URL, title: String, mainThumbnailURL: URL? = nil, mainThumbnail: ThumbnailImage? = nil, region: Region? = nil, covers: [Cover] = []) {
        self.url = url
        self.title = title
        self.mainThumbnailURL = mainThumbnailURL
        self.mainThumbnail = mainThumbnail
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
    var sortedUniqueCoverCategories: [String?] {
        let coverCategories: [String?] = covers.map({ $0.coverCategory })
        let uniqueCoverCategories = Set(coverCategories)
        return Array(uniqueCoverCategories).sorted { $0 ?? "" < $1 ?? "" }
    }

    var coversGroupedByCategory: [[Cover]] {
        sortedUniqueCoverCategories.map { category in
            let filteredCoverCategories = covers.filter { $0.coverCategory == category }
            let sorted = filteredCoverCategories.sorted {
                $0.coverCategory ?? "" < $1.coverCategory ?? ""
            }
            return sorted
        }
    }
}
