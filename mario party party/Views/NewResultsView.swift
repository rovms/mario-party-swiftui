//
//  ResultView.swift
//  mario party party
//
//  Created by Roman Bucher on 26/12/2023.
//

import SwiftUI

struct NewResultsView: View {
    
    @State private var speed = 0.0
    private var speedInt: Int {
        get {
            return Int(self.speed)
        }
    }
    @State private var isEditing = false
    
    var body: some View  {
        VStack {
                Slider(
                    value: $speed,
                    in: 0...7,
                    step: 1,
                    onEditingChanged: { editing in
                        isEditing = editing
                    }
                )
                Text("\(speedInt)")
                    .foregroundColor(isEditing ? .red : .blue)
            }
    }
}

#Preview {
    NewResultsView()
}
