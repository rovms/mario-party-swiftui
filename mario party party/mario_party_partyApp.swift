//
//  mario_party_partyApp.swift
//  mario party party
//
//  Created by Roman Bucher on 23/12/2023.
//

import SwiftUI
import Firebase

@main
struct mario_party_partyApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
