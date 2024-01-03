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
    var cumulativeScores: [Int] {
        if self.scores.isEmpty {
            return []
        } else {
            let sortedByDateScores = self.scores.sorted {
                $0.date < $1.date
            }
            var retCumulativeScores = [Int]()
            for i in self.scores.indices {
                if i == 0 {
                    retCumulativeScores.append(sortedByDateScores[0].value)
                } else {
                    retCumulativeScores.append(retCumulativeScores[i - 1] + sortedByDateScores[i].value)
                }
            }
            return retCumulativeScores
        }
    }
    
    init() {
        self.id = ""
        self.name = ""
        self.score = 0
        self.scores = [Score]()
    }
    
    init(id: String, name: String, score: Int, scores: [Score]) {
        self.id = id
        self.name = name
        self.score = score
        self.scores = scores
    }
}
