//
//  AllScoresView.swift
//  mario party party
//
//  Created by Roman Bucher on 23/01/2024.
//

import SwiftUI
import Charts

struct AllScoresView : View {
    @EnvironmentObject var userModel: UserModel
    @EnvironmentObject var scoreModel: ScoreModel
    
    @State var selectedMarioPartyVersion: MarioPartyVersion = .all
    @State var selectedYear: String = "Alle Jahre"
    
    var startYear: Int = 2020
    var currentYear: Int = Calendar.current.component(.year, from: Date())
    
    func availableYears() -> [String] {
        var availableYears = ["Alle Jahre"]
        for year in startYear..<currentYear + 1 {
            availableYears.append(String(year))
        }
        return availableYears
    }
    
    var body: some View {
        VStack {
            Picker("Spiel", selection: $selectedMarioPartyVersion) {
                Text("Alle Jahre").tag(MarioPartyVersion.all)
                Text("Mario Party 2").tag(MarioPartyVersion.marioParty2)
                Text("Mario Party 3").tag(MarioPartyVersion.marioParty3)
            }.pickerStyle(.segmented).padding()
            Picker("Jahr", selection: $selectedYear) {
                ForEach(availableYears(), id: \.self) { year in
                    Text(year)
                }
            }
            Chart {
                ForEach(userModel.users) { user in
                    ForEach(Array(user.cumulativeScores(game: selectedMarioPartyVersion, year: selectedYear).enumerated()), id: \.offset) { (i, score) in
                        LineMark(
                            x: .value("Month", i), y: .value("Scores", score.cumulativeValue)
                        ).foregroundStyle(by: .value("name", user.name))
                    }
                }
            }.padding()
        }
    }
}

