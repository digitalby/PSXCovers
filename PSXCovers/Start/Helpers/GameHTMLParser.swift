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
        
        
        let game = Game(title: gameTitle, region: region, covers: [])
        return game
    }
}

