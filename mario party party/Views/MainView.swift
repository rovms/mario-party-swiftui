//
//  ContentView.swift
//  mario party party
//
//  Created by Roman Bucher on 23/12/2023.
//

import SwiftUI

struct MainView: View {
    
    @ObservedObject var userModel = UserModel()
    @ObservedObject var scoreModel = ScoreModel()
        
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    NavigationLink(destination: ScoresView()) {
                        Text("Resultate")
                    }
                    NavigationLink(destination: NewResultsView()) {
                        Text("Neue Resultate")
                    }
                }
            }
        }
        .padding()
    }
    
    init() {
        userModel.getData()
    }
}

#Preview {
    MainView()
}
