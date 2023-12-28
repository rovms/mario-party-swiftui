//
//  ResultView.swift
//  mario party party
//
//  Created by Roman Bucher on 25/12/2023.
//

import SwiftUI

struct ScoresView: View {
    //@ObservedObject var userModel = UserModel()
    @ObservedObject var scoreModel = ScoreModel()
    
    var body: some View  {
        VStack {
            List(scoreModel.scores) { score in
                Text(String(score.value))
            }.onAppear {
                //userModel.getUsers()
                scoreModel.getScores()
            }
        }
    }
    
    init() {
        //userModel.getUsers()
        scoreModel.getScores()
    }
}

#Preview {
    ScoresView()
}
