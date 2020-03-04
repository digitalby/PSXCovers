//
//  Game.swift
//  PSXCovers
//
//  Created by Digital on 25/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import Foundation
import RealmSwift

class Game: Object {
    @objc dynamic private var _url: String? = nil
    var url: URL? {
        get {
            URL(string: _url ?? "")
        }
        set {
            _url = newValue?.absoluteString
        }
    }
    @objc dynamic var title: String? = nil
    @objc dynamic private var _mainThumbnailURL: String? = nil
    var mainThumbnailURL: URL? {
        get {
            URL(string: _mainThumbnailURL ?? "")
        }
        set {
            _mainThumbnailURL = newValue?.absoluteString
        }
    }

    var covers: [Cover] {
        get {
            return _covers.map { $0 }
        }
        set {
            _covers.removeAll()
            _covers.append(objectsIn: newValue.map { $0 } )
        }
    }
    private let _covers = List<Cover>()

    @objc dynamic private var _mainThumbnail: PersistentThumbnailImage? = nil
    var mainThumbnail: ThumbnailImage? {
        get { _mainThumbnail?.thumbnailImage }
        set {
            _mainThumbnail = PersistentThumbnailImage()
            _mainThumbnail?.thumbnailImage = newValue
        }
    }

    @objc dynamic private var _region: String? = nil
    var region: Region? {
      get { Region(rawValue: _region ?? "") }
      set { _region = newValue?.rawValue }
    }

    convenience init(url: URL? = nil, title: String? = nil, mainThumbnailURL: URL? = nil, mainThumbnail: ThumbnailImage? = nil, region: Region? = nil, covers: [Cover]? = []) {
        self.init()
        self.url = url
        self.title = title
        self.mainThumbnailURL = mainThumbnailURL
        self.mainThumbnail = mainThumbnail
        self.region = region
        self.covers = covers ?? []
    }
}

//MARK: - Title/Region Helpers
extension Game {
    var titleWithRegion: String {
        guard var title = self.title else { return "" }
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
