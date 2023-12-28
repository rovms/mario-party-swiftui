//
//  ResultView.swift
//  mario party party
//
//  Created by Roman Bucher on 27/12/2023.
//

import SwiftUI

struct PlayerSlider: View {
    
    @State private var score = 0.0
    
    private var scoreInt: Int {
        get {
            return Int(self.score)
        }
    }
    @State private var isEditing = false
    
    @State var user: User
    var userModel: UserModel
    
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
                            self.user.score = Int(newVal)
                            self.userModel.updateScore(userId: user.id, newScore: Int(newVal))
                        }
                    ),
                in: 0...7,
                step: 1,
                onEditingChanged: { editing in
                    isEditing = editing
                }
            )
            Text("\(scoreInt)")
                .foregroundColor(isEditing ? .red : .blue)
        }.padding()
    }
    
    init(user: User, userModel: UserModel) {
        self.user = user
        self.userModel = userModel
    }
}

