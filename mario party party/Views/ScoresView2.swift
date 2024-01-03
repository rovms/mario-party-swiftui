//
//  ResultView.swift
//  mario party party
//
//  Created by Roman Bucher on 31/12/2023.
//

import SwiftUI
import Charts


struct ScoresView2: View {
    @ObservedObject var userModel = UserModel()
    
    var body: some View  {
        VStack {
            List(userModel.users) { user in
                HStack {
                    Text(user.name)
                    Spacer()
                    Text(user.id)
                }
            }
            
            ForEach(userModel.users) { user in
                    Text(user.name)
                    Text("Scores")
                    ForEach(user.scores) { score in
                        Text(String(score.value))
                    }
                
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
        userModel.getUsers()
    }
}

#Preview {
    ScoresView2()
}
