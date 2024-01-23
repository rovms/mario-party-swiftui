//
//  ScoreDetailsTableView.swift
//  mario party party
//
//  Created by Roman Bucher on 23/01/2024.
//

import SwiftUI

struct ScoreDetailsTableView: View {
    @EnvironmentObject var scoreModel: ScoreModel
    @EnvironmentObject var userModel: UserModel
    
    @Environment(\.dismiss) var dismiss
    
    func getUserName(userId: String) -> String {
        let user = userModel.users.first(where: {
            $0.id == userId
        })
        return user != nil ? user!.name : ""
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.YY HH:mm"
        return formatter
    }()
    
    func deleteScores(scores: [Score]) {
        scores.forEach { score in
            scoreModel.delete(score: score)
        }
        dismiss()
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(userModel.scoresGroupedByDate().sorted(by: {$0.key > $1.key}), id: \.key) { group, scores in
                    Section {
                        ForEach(scores.sorted(by: { $0.userId < $1.userId })) { score in
                            HStack {
                                Text(self.getUserName(userId: score.userId))
                                Spacer()
                                Text(score.value.description)
                                
                            }
                        }
                    }
                header: {
                    HStack {
                        Text(self.dateFormatter.string(from: scores[0].date))
                        Spacer()
                        Button("Löschen"){
                            deleteScores(scores: scores)
                        }.tint(.red)
                    }
                }
                }
            }
        }
    }
}
