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
    var totalScore: Int {
        if self.scores.isEmpty {
            return 0
        } else {
            var total = 0
            self.scores.forEach { score in
                total += score.value
            }
            return total
        }
    }
    
    var cumulativeScores: [Score] {
        if self.scores.isEmpty {
            return []
        } else {
            var sortedByDateScores = self.scores.sorted {
                $0.date < $1.date
            }
            var retCumulativeScores = [Score]()
            for i in self.scores.indices {
                print("iiiiii")
                print(i)
                if i == 0 {
                    print(" i == 0")
                    
                    sortedByDateScores[i].cumulativeValue = sortedByDateScores[i].value
                    print(sortedByDateScores[i].cumulativeValue)
                } else {
                    print(" i > 0")

                    sortedByDateScores[i].cumulativeValue = sortedByDateScores[i - 1].value + sortedByDateScores[i].value
                    print(sortedByDateScores[i].cumulativeValue)

                }
                retCumulativeScores.append(sortedByDateScores[i])

            }
            
            print("cumulative scores")
            print(name)
            print(retCumulativeScores)
            
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
