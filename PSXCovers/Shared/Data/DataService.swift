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
    static let realm = try! Realm()
    static let shared = DataService()

    lazy var data: Results<Game> = {
        type(of: self).realm.objects(Game.self).sorted(byKeyPath: "_region").sorted(byKeyPath: "title")
    }()
    var uniqueFirstLetters: [String] {
        var firstLetters = [String]()
        for game in data {
            guard var letter = game.title?.first?.uppercased() else { continue }
            if letter.rangeOfCharacter(from: .letters) == nil {
                letter = "#"
            }
            firstLetters.append(String(letter))
        }
        return Array(Set(firstLetters)).sorted()
    }
    var sectionedData: [[Game]] {
        uniqueFirstLetters.map { lhs in
            let filtered = data.filter {
                guard let charRHS = $0.title?.first else { return false }
                var rhs = String(charRHS)
                if rhs.rangeOfCharacter(from: .letters) == nil {
                    rhs = "#"
                }
                return lhs == String(rhs)
            }
            return filtered.sorted { $0.title ?? "" < $1.title ?? "" }
        }
    }
}

//MARK: - Convenience methods
extension DataService {
    func add(game: Game) throws {
        let results = games(matching: game)
        guard results.count == 0 else { return }
        try type(of: self).realm.write {
            type(of: self).realm.add(game)
        }
    }

    func delete(game: Game) throws {
        let results = games(matching: game)
        guard results.count == 1 else { return }
        try type(of: self).realm.write {
            let results = games(matching: game)
            type(of: self).realm.delete(results)
        }
    }

    func isGameFavorite(_ game: Game) -> Bool {
        games(matching: game).count > 0
    }

    func games(matching game: Game) -> Results<Game> {
        gamesWith(url: game.url)
    }

    func gamesWith(url: URL?) -> Results<Game> {
        let data = DataService.shared.data.filter(
            "(_url=%@)",
            url?.absoluteString as Any
        )
        return data
    }

    func gamesWith(title: String?, region: Region?) -> Results<Game> {
        DataService.shared.data.filter(
            "(title=%@) AND (_region=%@)",
            title as Any,
            region?.rawValue as Any
        )
    }
}
