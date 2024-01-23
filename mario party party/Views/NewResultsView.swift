//
//  NewResultsView.swift
//  mario party party
//
//  Created by Roman Bucher on 23/01/2024.
//

import SwiftUI

struct NewResultsView: View {
    
    @EnvironmentObject var userModel: UserModel
    @EnvironmentObject var scoreModel: ScoreModel
    
    @State private var date = Date()
    @State private var invalidScore = false
    @State private var selectedMarioPartyVersion: MarioPartyVersion = .marioParty2
    
    @Environment(\.dismiss) var dismiss
    
    func validateScores() -> Bool {
        var maxScoreCount = 0
        self.userModel.users.forEach { user in
            if (user.score == 7) {
                maxScoreCount += 1
            }
        }
        if (maxScoreCount != 1) {
            invalidScore = true
            return false
        }
        return true
    }
    
    func storeScore() {
        if (!validateScores()) {
            return
        }
        self.userModel.users.forEach { user in
            scoreModel.addScores(
                score: Score(
                    value: user.score,
                    date: self.date,
                    userId: user.id,
                    game: selectedMarioPartyVersion.rawValue
                ), userModel: userModel)
        }
        dismiss()
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                DatePicker(
                    selection: $date,
                    displayedComponents: [.date, .hourAndMinute],
                    label: { Text("Datum").foregroundStyle(.gray) }
                )
            }.padding(.leading).padding(.trailing)
            Spacer()
            Picker("Spiel", selection: $selectedMarioPartyVersion) {
                Text("Mario Party 2").tag(MarioPartyVersion.marioParty2)
                Text("Mario Party 3").tag(MarioPartyVersion.marioParty3)
            }.pickerStyle(.segmented).padding()
            Spacer()
            Divider()
            Spacer()
            ForEach(userModel.users) { user in
                PlayerSliderView(user: user).environmentObject(userModel)
            }
            Spacer()
            Divider()
            Spacer()
            Button("Speichern") {
                storeScore()
            }.buttonStyle(.bordered).tint(.green).alert("Ungültiges Resultat", isPresented: $invalidScore) {
                Button("Ok", role: .cancel) { }
            }
        }.padding().presentationDetents([.height(500)])
        
    }
}

