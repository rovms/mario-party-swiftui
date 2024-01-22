//
//  ContentView.swift
//  mario party party
//
//  Created by Roman Bucher on 23/12/2023.
//

import SwiftUI
import Charts
import Foundation

struct ContentView: View {
    
    @ObservedObject var userModel = UserModel()
    @ObservedObject var scoreModel = ScoreModel()
    @State var addingNewScores = false
    
    var body: some View {
        VStack {
            Text("MARIO PARTY").font(Font.custom("Lemon-Regular", size: 32)).padding(.bottom)
            /**
             VStack {
             VStack {
             ForEach(userModel.usersSortedByScore()) { user in
             HStack {
             Text(user.name).font(Font.custom("Lemon-Regular", size: 18)).padding(.leading)
             Spacer()
             Text(String(user.totalScore)).font(Font.custom("Lemon-Regular", size: 18)).padding(.trailing)
             }
             }.padding(.bottom)
             }
             }
             */
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
    
    init() {
        userModel.getData()
        userModel.getUpdatedScores()
    }
}

struct NewResultsSheetView: View {
    
    enum MarioPartyVersion: CaseIterable, Identifiable {
        case marioParty2
        case marioParty3
        
        var id: Self { self }
        
        var describing: String {
            switch self {
            case .marioParty2:
                
                return "Mario Party 2"
            case .marioParty3:
                return "Mario Party 3"
            }
        }
        
        var dbValue: String {
            switch self {
            case .marioParty2:
                return "marioParty2"
            case .marioParty3:
                return "marioParty3"
            }
        }
    }
    
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
                    game: selectedMarioPartyVersion.dbValue
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
                ForEach(MarioPartyVersion.allCases) { mpVersion in
                    Text(mpVersion.describing)
                }
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
    
    let dateFormatter: DateFormatter
    
    
    func getUserColor(userId: String) -> Color {
        if (userId == "9IIYk73UzoykFr3xYI1Z") {
            print("blue")
            return .blue
        }
        if (userId == "XwqeifWwtB0nONsCjDwq") {
            print("green")

            return .green
        }
        if (userId == "lX6VznwQ8j0CqiiG5BUS") {
            print("yellow")

            return .yellow
        }
        if (userId == "yNnW9URqFoarjA8Uq8Km") {
            print("red")

            return .red
        }
        return .gray
    }
    
    var body: some View {
        ForEach(userModel.scores) { score in
            HStack {
                Text(score.id).font(.system(size: 10))
                Spacer()
                Text(dateFormatter.string(from: score.date)).font(.system(size: 10))
                Spacer()
                Text(score.userId).font(.system(size: 10))
                Spacer()
                Text(String(score.value)).font(.system(size: 10))
            }
        }
        
        Chart {
            ForEach(userModel.users) { user in
                ForEach(Array(user.cumulativeScores.enumerated()), id: \.offset) { (i, score) in
                    LineMark(
                        x: .value("Month", i + 1), y: .value("Scores", score.cumulativeValue)
                    ).foregroundStyle(by: .value("userId", score.userId))
                }
            }
            
        }
        /**
         
         Chart {
         ForEach(Array(data.enumerated()), id: \.offset) { (i, order) in
         LineMark(
         x: .value("Month", order.day), y: .value("Orders", order.amount)
         ).foregroundStyle(.gray)
         
         }
         ForEach(Array(data2.enumerated()), id: \.offset) { (i, order) in
         LineMark(
         x: .value("Month", order.day), y: .value("Orders", order.amount)
         ).foregroundStyle(.green)
         
         }
         }
         */
        
        /**
         
         Chart {
         ForEach(userModel.users) { user in
         ForEach(Array(zip(user.scores)) { (i, score) in
         LineMark(
         x: .value("Index", i),
         y: .value("Points", score.value)
         )
         .interpolationMethod(.linear)
         .foregroundStyle(by: .value("Spieler", user.name))
         }
         }
         }
         
         
         Chart(UserModel.scores) {
         LineMark(
         x: .value("Datum", $0.date),
         y: .value("Punkte", $0.value)
         ).foregroundStyle(by: .value("Spieler", $0.userId))
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
    
    init() {
        self.dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-YY"
    }
}

#Preview {
    ContentView()
}
