//
//  ContentView.swift
//  mario party party
//
//  Created by Roman Bucher on 23/12/2023.
//

import SwiftUI

// let background = LinearGradient(gradient: Gradient(colors: [.red, .green, .yellow, .blue, .pink]), startPoint: .topLeading, endPoint: .bottomTrailing).edgesIgnoringSafeArea(.all)

struct ContentView: View {
    
    @ObservedObject var userModel = UserModel()
    @ObservedObject var scoreModel = ScoreModel()
    @State var addingNewScores = false
        
    var body: some View {
        VStack {
            Text("MARIO PARTY").font(Font.custom("Lemon-Regular", size: 32)).padding(.bottom)
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
                Spacer()
                Button(action: {
                    self.addingNewScores.toggle()
                }) {
                    Text("Neue Resultate").font(.custom("Lemon-Regular", size: 20))
                
            }
        }.sheet(isPresented: $addingNewScores,
                content: {
            NewResultsSheetView(users: userModel.users).environmentObject(scoreModel).environmentObject(userModel)
                }
        ).font(.custom("Lemon-Regular", size: 18)).padding()
    }
    
    init() {
        userModel.getData()
        userModel.getUpdatedScores()
    }
}

struct NewResultsSheetView: View {
    
    var users: [User]
    @EnvironmentObject var userModel: UserModel
    @EnvironmentObject var scoreModel: ScoreModel
    
    @State private var date = Date()
    @State private var validScore = true

    @Environment(\.dismiss) var dismiss
    
    func validateScores() {
        var maxScoreCount = 0
        self.users.forEach { user in
            if (user.score == 7) {
                maxScoreCount += 1
            }
        }
        if (maxScoreCount != 1) {
            validScore = false
        }
    }
    
    func storeScore() {
        
        self.users.forEach { user in
            scoreModel.addScores(
                score: Score(
                    value: user.score,
                    date: self.date,
                    userId: user.id
                ), userModel: userModel)
        }
        dismiss()
        
    }
    
    var body: some View {
        VStack {
            DatePicker(
                "Datum",
                selection: $date,
                displayedComponents: [.date, .hourAndMinute]
            )
            ForEach(users) { user in
                PlayerSlider2(user: user).environmentObject(userModel)
            }
            Button(action: storeScore) {
                Text("Speichern")
            }
        }.padding()
            //.alert("Noooooo", isPresented: $validScore) {
            //Button("Ok", role: .cancel) { }
        //}
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
        HStack(alignment: .firstTextBaseline) {
            Text(user.name)
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
            ).tint(scoreColor())
            Text("\(scoreInt)")
                .foregroundColor(isEditing ? randomColor() : scoreColor())
        }.padding()
    }
    
    init(user: User) {
        self.user = user
    }
}

#Preview {
    ContentView()
}
