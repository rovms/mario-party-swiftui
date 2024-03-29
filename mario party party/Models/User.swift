//
//  User.swift
//  mario party party
//
//  Created by Roman Bucher on 24/12/2023.
//

import Foundation

struct User: Identifiable {
    
    var id: String
    var name: String
    var score: Int
    var scores: [Score]
    
    func cumulativeScores(game: MarioPartyVersion, year: String) -> [Score] {
        if self.scores.isEmpty {
            return []
        } else {
            var filteredScores = self.scores
            if (game != .all) {
                filteredScores = self.scores.filter {
                    $0.game == game.rawValue
                }
            }
            if (year != "Alle Jahre") {
                filteredScores = filteredScores.filter {
                    Calendar.current.component(.year, from: $0.date) == Int(year)
                }
            }
            var sortedByDateScores = filteredScores.sorted {
                $0.date < $1.date
            }
            var retCumulativeScores = [Score]()
            for i in sortedByDateScores.indices {
                if i == 0 {
                    sortedByDateScores[i].cumulativeValue = sortedByDateScores[i].value
                } else {
                    sortedByDateScores[i].cumulativeValue = sortedByDateScores[i - 1].cumulativeValue + sortedByDateScores[i].value
                }
                retCumulativeScores.append(sortedByDateScores[i])
                
            }
            
            return retCumulativeScores
            
        }
    }
    
    init(id: String, name: String, score: Int, scores: [Score]) {
        self.id = id
        self.name = name
        self.score = score
        self.scores = scores
    }
}
