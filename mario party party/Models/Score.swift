//
//  Score.swift
//  mario party party
//
//  Created by Roman Bucher on 27/12/2023.
//

import Foundation

struct Score: Identifiable {
    var id: String
    var value: Int
    var date: Date
    var userId: String
    
    init(id: String, value: Int, date: Date, userId: String) {
        self.id = id
        self.value = value
        self.date = date
        self.userId = userId
    }
    
    init(value: Int, date: Date, userId: String) {
        self.id = ""
        self.value = value
        self.date = date
        self.userId = userId
    }
}
