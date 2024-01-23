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
    @State var isSignedIn = false
    
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
                Button(action: {
                    self.addingNewScores.toggle()
                }) {
                    Text("Neue Resultate").font(.custom("Lemon-Regular", size: 24))
                }.padding().buttonStyle(.bordered).tint(.orange)
            }.sheet(isPresented: $addingNewScores,
                    content: {
                NewResultsSheetView(users: userModel.users).environmentObject(scoreModel).environmentObject(userModel)
            }
            ).font(.custom("Lemon-Regular", size: 16)).padding()
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

struct Order: Identifiable {
    var id: String = UUID().uuidString
    var amount: Int
    var day: Int
}

struct ScoreView : View {
    @EnvironmentObject var userModel: UserModel
    @EnvironmentObject var scoreModel: ScoreModel
    
    @State var selectedMarioPartyVersion: MarioPartyVersion = .all
    
    var body: some View {
        VStack {
            Picker("Spiel", selection: $selectedMarioPartyVersion) {
                Text("Alle").tag(MarioPartyVersion.all)
                Text("Mario Party 2").tag(MarioPartyVersion.marioParty2)
                Text("Mario Party 3").tag(MarioPartyVersion.marioParty3)
            }.pickerStyle(.segmented).padding()
            Chart {
                ForEach(userModel.users) { user in
                    ForEach(Array(user.cumulativeScores.enumerated()), id: \.offset) { (i, score) in
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
