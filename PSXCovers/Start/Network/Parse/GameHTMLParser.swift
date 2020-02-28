//
//  GameHTMLParser.swift
//  PSXCovers
//
//  Created by Digital on 25/02/2020.
//  Copyright © 2020 digitalby. All rights reserved.
//

import Foundation
import HTMLReader

class GameHTMLParser {
    let gameURL: URL

    init(gameURL: URL) {
        self.gameURL = gameURL
    }

    func makeGame(fromHTML html: String) -> Game {
        let doc = HTMLDocument(string: html)
        let gameDescriptionTable = doc.firstNode(matchingSelector: "#table4")
        var gameTitle = ""
        var region: Region? = nil
        if let descriptionTableRows = gameDescriptionTable?
            .firstNode(matchingSelector: "tbody")?
            .nodes(matchingSelector: "tr") {
            for tr in descriptionTableRows {
                let nodes = tr.nodes(matchingSelector: "td")
                let firstNodeText = nodes
                    .first?
                    .textContent
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                let lastNodeText = nodes
                    .last?
                    .textContent
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    ?? ""
                switch firstNodeText {
                case "Region":
                    guard region == nil else { continue }
                    region = Region(fromString: lastNodeText)
                case "Official Title":
                    guard gameTitle == "" else { continue }
                    gameTitle = lastNodeText
                default: continue
                }
            }
        }

        let gameCoversTables = doc.nodes(matchingSelector: "#table28")
        let gameDiscTables = doc.nodes(matchingSelector: "#table29")
        var covers = gameCoversTables.flatMap {
            getCovers(fromTable: $0)
        }
        covers.append(contentsOf: gameDiscTables.flatMap {
            getCovers(fromTable: $0)
        })

        let game = Game(url: gameURL, title: gameTitle, region: region, covers: covers)
        return game
    }
}

//MARK: - Helpers
private extension GameHTMLParser {
    func getCovers(fromTable node: HTMLNode) -> [Cover] {
        var array = [Cover]()
        guard let tbody = node.firstNode(matchingSelector: "tbody")
            else { return array }
        let rows = tbody.nodes(matchingSelector: "tr")
        guard rows.count == 4
            else { return array }

        let categoryRow = rows[0]
        let category = categoryRow
            .firstNode(matchingSelector: "td")?
            .textContent
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let labelRow = rows[1]
        let labelCols = labelRow.nodes(matchingSelector: "td")
        let thumbnailRow = rows[2]
        let thumbnailCols = thumbnailRow.nodes(matchingSelector: "td")
        let labels = labelCols
            .map { $0
                .textContent
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }.filter { !$0.isEmpty }
        let fullResLinks = thumbnailCols.flatMap { $0.nodes(matchingSelector: "a") }
        let thumbnailImgs = thumbnailCols.flatMap { $0.nodes(matchingSelector: "img") }
        var fullResHTMLHrefs = fullResLinks
            .map { $0.attributes["href"] }
            .map {
                $0?.replacingOccurrences(
                    of: #"\.html"#,
                    with: #".jpg"#,
                    options: [.regularExpression]
                )
        }
        let thumbnailSrcs = thumbnailImgs.map { $0.attributes["src"] }
        let delta = thumbnailSrcs.count - fullResHTMLHrefs.count
        for _ in 0..<delta {
            fullResHTMLHrefs.append(nil)
        }
        guard
            labels.count == thumbnailSrcs.count,
            labels.count == fullResHTMLHrefs.count
        else { return array }
        for i in 0..<labels.count {
            var thumbnailURL: URL? = nil
            var fullSizeURL: URL? = nil
            if let thumbnailURLString = thumbnailSrcs[i] {
                thumbnailURL = URL(string: thumbnailURLString, relativeTo: gameURL)
            }
            if let fullSizeURLString = fullResHTMLHrefs[i] {
                fullSizeURL = URL(string: fullSizeURLString, relativeTo: gameURL)
            }
            let cover = Cover(
                thumbnailImageURL: thumbnailURL?.absoluteURL,
                fullSizeImageURL: fullSizeURL?.absoluteURL,
                coverCategory: category,
                coverLabel: labels[i]
            )
            array.append(cover)
        }

        return array
    }
}
