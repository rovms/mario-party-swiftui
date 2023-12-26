//
//  ContentView.swift
//  mario party party
//
//  Created by Roman Bucher on 23/12/2023.
//

import SwiftUI

struct MainView: View {
        
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    NavigationLink(destination: ResultView()) {
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
}

#Preview {
    MainView()
}
