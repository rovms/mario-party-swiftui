//
//  ResultView.swift
//  mario party party
//
//  Created by Roman Bucher on 25/12/2023.
//

import SwiftUI

struct ResultView: View {
    @ObservedObject var model = ViewModel()
    
    var body: some View  {
        List(model.users) { user in
            Text(user.name)
        }.onAppear {
            print("helloo")
            model.getUsers()
        }
    }
    
    init() {
        model.getUsers()
    }
}

#Preview {
    ResultView()
}
