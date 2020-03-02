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
        let gameDescriptionTable = doc.firstNode(matchingSelector: "#table4") ?? HTMLElement()
        let title = getTitle(fromTable: gameDescriptionTable) ?? ""
        let region = getRegion(fromTable: gameDescriptionTable)
        let gameCoversTables = doc.nodes(matchingSelector: "#table28")
        let gameDiscTables = doc.nodes(matchingSelector: "#table29")
        var covers = gameCoversTables.flatMap {
            getCovers(fromTable: $0)
        }
        covers.append(contentsOf: gameDiscTables.flatMap {
            getCovers(fromTable: $0)
        })

        let game = Game(url: gameURL, title: title, region: region, covers: covers)
        return game
    }
}

//MARK: - Helpers
private extension GameHTMLParser {
    func getRows(fromTable node: HTMLNode) -> [HTMLNode] {
        if let tableRows = node
            .firstNode(matchingSelector: "tbody")?
            .nodes(matchingSelector: "tr") {
            return tableRows
        }
        return []
    }

    func makeTuple(fromRow node: HTMLNode) -> (String?, String?)? {
        let nodes = node.nodes(matchingSelector: "td")
        guard nodes.count == 2 else { return nil }
        let firstNodeText = nodes
            .first?
            .textContent
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let lastNodeText = nodes
            .last?
            .textContent
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return (firstNodeText, lastNodeText)
    }

    func getTitle(fromTable node: HTMLNode) -> String? {
        for tr in getRows(fromTable: node) {
            if let tuple = makeTuple(fromRow: tr) {
                if tuple.0 == "Official Title" {
                    return tuple.1
                }
            }
        }
        return nil
    }

    func getRegion(fromTable node: HTMLNode) -> Region? {
        for tr in getRows(fromTable: node) {
            if let tuple = makeTuple(fromRow: tr) {
                if tuple.0 == "Region" {
                    return Region(fromString: tuple.1 ?? "")
                }
            }
        }
        return nil
    }

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
