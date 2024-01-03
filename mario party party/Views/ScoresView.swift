//
//  ResultView.swift
//  mario party party
//
//  Created by Roman Bucher on 25/12/2023.
//

import SwiftUI
import Charts


struct ScoresView: View {
    @ObservedObject var userModel = UserModel()
    @ObservedObject var scoreModel = ScoreModel()
    
    var body: some View  {
        VStack {
            List(scoreModel.scores) { score in
                HStack {
                    Text(score.userId)
                    Spacer()
                    Text(String(score.value))
                }
            }.onAppear {
                scoreModel.getScores()
            }
            
            /**
            Chart(scoreModel.enrichedScores) {
                LineMark(
                    x: .value("Datum", $0.date),
                    y: .value("Punkte", $0.value)
                ).foregroundStyle(by: .value("Spieler", $0.userId))
            }.onAppear {
                scoreModel.getScores()
            }
           
            Chart {
                ForEach(userModel.users) { user in
                    ForEach(scoreModel.getScoresByUserId(userId: user.id), id: \.date) { score in
                        LineMark(
                           x: .value("Spiel", score.date),
                           y: .value("Punkte", score.value),
                           series: .value("User", score.userId)
                       )
                    }
                }
            }.onAppear {
                scoreModel.getScores()
            }
             */
        }
    }
    
    init() {
        scoreModel.getScores()
        scoreModel.getUpdatedScores()
    }
}

#Preview {
    ScoresView()
}
