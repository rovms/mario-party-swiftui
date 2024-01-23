//
//  ContentView.swift
//  mario party party
//
//  Created by Roman Bucher on 23/12/2023.
//

import SwiftUI
import Charts
import Foundation
import FirebaseAuth

struct ContentView: View {
    
    @ObservedObject var userModel = UserModel()
    @ObservedObject var scoreModel = ScoreModel()
    @State var addingNewScores = false
    @State var showScoreDetailsTable = false
    @State var isSignedIn = true //TODO: set to false
    
    @State var email = ""
    @State var password = ""
    @FocusState private var emailFieldIsFocused: Bool
    @FocusState private var passwordFieldIsFocused: Bool
    @State private var invalidEmailPassword = false
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if error != nil {
                invalidEmailPassword = true
                return
            }
            isSignedIn = true
        }
    }
    
    var body: some View {
        if isSignedIn {
            VStack {
                Text("MARIO PARTY").font(Font.custom("Lemon-Regular", size: 32)).padding(.bottom)
                ScoreView().environmentObject(userModel).environmentObject(scoreModel)
                Spacer()
                HStack {
                    Button(action: {
                        self.addingNewScores.toggle()
                    }) {
                        Text("Neue Resultate").font(.custom("Lemon-Regular", size: 24))
                    }.padding().buttonStyle(.bordered).tint(.orange)
                    Button(action: {
                        self.showScoreDetailsTable.toggle()
                    }) {
                        Image(systemName: "tablecells.badge.ellipsis").font(.title).foregroundStyle(.black)
                    }
                }
            }.sheet(isPresented: $addingNewScores,
                    content: {
                NewResultsSheetView(users: userModel.users).environmentObject(scoreModel).environmentObject(userModel)
            }).sheet(isPresented: $showScoreDetailsTable,
                     content: {
                ScoreDetailsTableView().environmentObject(scoreModel).environmentObject(userModel)
            })
        }
        if !isSignedIn {
            VStack {
                TextField("Benutzer (Email)", text: $email).keyboardType(.emailAddress).focused($emailFieldIsFocused).textInputAutocapitalization(.never).autocorrectionDisabled().padding().border(.secondary).padding()
                SecureField("Passwort", text: $password).padding().border(.secondary).padding()
                Button("Login") {
                    login()
                }.buttonStyle(.bordered).tint(.green).alert("Login fehlgeschlagen", isPresented: $invalidEmailPassword) {
                    Button("Ok", role: .cancel) { }
                }
            }.font(.custom("Lemon-Regular", size: 18))
        }
    }
    
    init() {
        userModel.getData()
        userModel.getUpdatedScores()
        if Auth.auth().currentUser != nil {
            self.isSignedIn = true
        }
    }
}

struct ScoreDetailsTableView: View {
    @EnvironmentObject var scoreModel: ScoreModel
    @EnvironmentObject var userModel: UserModel
    
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
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(userModel.scoresGroupedByDate().sorted(by: {$0.key < $1.key}), id: \.key) { group, scores in
                    Section {
                        ForEach(scores) { score in
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

struct NewResultsSheetView: View {
    
    var users: [User]
    @EnvironmentObject var userModel: UserModel
    @EnvironmentObject var scoreModel: ScoreModel
    
    @State private var date = Date()
    @State private var invalidScore = false
    @State private var selectedMarioPartyVersion: MarioPartyVersion = .marioParty2
    
    @Environment(\.dismiss) var dismiss
    
    func validateScores() -> Bool {
        var maxScoreCount = 0
        self.users.forEach { user in
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
        self.users.forEach { user in
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
            ForEach(users) { user in
                PlayerSlider2(user: user).environmentObject(userModel)
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
    
    init(users: [User]) {
        self.users = users
    }
}

struct PlayerSlider2: View {
    
    let COLORS = [Color.red, Color.green, Color.blue, Color.yellow]
    
    @State private var score = 0.0
    @EnvironmentObject var userModel: UserModel
    
    private var scoreInt: Int {
        get {
            return Int(self.score)
        }
    }
    @State private var isEditing = false
    
    var user: User
    
    func randomColor() -> Color {
        guard let randomColor = COLORS.randomElement() else { return Color.blue }
        return randomColor
    }
    
    func scoreColor() -> Color {
        if (scoreInt < 3) {
            return Color.red
        }
        if (scoreInt < 5) {
            return Color.yellow
        }
        if (scoreInt < 7) {
            return Color.blue
        }
        return Color.green
    }
    
    
    var body: some View  {
        HStack() {
            Text(user.name)
            Spacer()
            Slider(
                value:
                    Binding(
                        get: {
                            self.score
                        },
                        set: { (newVal) in
                            self.score = newVal
                            self.userModel.updateScore(userId: user.id, newScore: Int(newVal))
                        }
                    ),
                in: 0...7,
                step: 1,
                onEditingChanged: { editing in
                    isEditing = editing
                }
            ).tint(scoreColor()).frame(width: 220)
            Text("\(scoreInt)")
                .foregroundColor(isEditing ? randomColor() : scoreColor())
        }.padding()
    }
    
    init(user: User) {
        self.user = user
    }
}

struct ScoreView : View {
    @EnvironmentObject var userModel: UserModel
    @EnvironmentObject var scoreModel: ScoreModel
    
    @State var selectedMarioPartyVersion: MarioPartyVersion = .all
    @State var selectedYear: String = "Alle"
    
    var startYear: Int = 2020
    var currentYear: Int = Calendar.current.component(.year, from: Date())
    
    func availableYears() -> [String] {
        var availableYears = ["Alle"]
        for year in startYear..<currentYear + 1 {
            availableYears.append(String(year))
        }
        return availableYears
    }
    
    var body: some View {
        VStack {
            Picker("Spiel", selection: $selectedMarioPartyVersion) {
                Text("Alle").tag(MarioPartyVersion.all)
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
            }
        }
    }
}

#Preview {
    ContentView()
}
