//
//  MarioPartyVersion.swift
//  mario party party
//
//  Created by Roman Bucher on 22/01/2024.
//

import Foundation

enum MarioPartyVersion: String, CaseIterable, Identifiable {
    case all
    case marioParty2
    case marioParty3
    
    var id: Self { self }
}
