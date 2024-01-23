//
//  ContentView.swift
//  mario party party
//
//  Created by Roman Bucher on 23/12/2023.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    
    @ObservedObject var userModel = UserModel()
    @ObservedObject var scoreModel = ScoreModel()
    @State var addingNewScores = false
    @State var showScoreDetailsTable = false
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
                AllScoresView().environmentObject(userModel).environmentObject(scoreModel)
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
                        Image(systemName: "tablecells.badge.ellipsis").font(.title).tint(.gray)
                    }
                }
            }.sheet(isPresented: $addingNewScores,
                    content: {
                NewResultsView().environmentObject(scoreModel).environmentObject(userModel)
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

#Preview {
    ContentView()
}
