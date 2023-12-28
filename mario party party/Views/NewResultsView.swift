//
//  ResultView.swift
//  mario party party
//
//  Created by Roman Bucher on 26/12/2023.
//

import SwiftUI


struct NewResultsView: View {
    
    @State private var speed = 0.0
    private var speedInt: Int {
        get {
            return Int(self.speed)
        }
    }
    @State private var isEditing = false
    
    @ObservedObject var model = UserModel()
    @ObservedObject var scoreModel = ScoreModel()
    
    func storeScore() {
        model.users.forEach { user in
            scoreModel.addScores(score: Score(value: user.score, date: Date(), userId: user.id))
            }
    }
    
    var body: some View  {
        VStack {
            ForEach(model.users) { user in
                PlayerSlider(user: user, userModel: model)
            }
            Button(action: storeScore) {
                Text("Speichern")
            }
            List(model.users) { user in
                Text(user.name + ": " + String(user.score))
            }
        }
    }
    init() {
        model.getUsers()
    }
}

#Preview {
    NewResultsView()
}
