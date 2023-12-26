//
//  ViewModel.swift
//  mario party party
//
//  Created by Roman Bucher on 24/12/2023.
//

import Foundation
import Firebase

class ViewModel: ObservableObject {
    @Published var users = [User]()
    
    func getUsers() {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    DispatchQueue.main.async {
                        self.users = snapshot.documents.map { user in
                            print(snapshot.documents)
                            return User(id: user.documentID, name: user["name"] as? String ?? "")
                        }
                    }
                }
            } else {
                
            }
        }
    }
    
    func addPoints(points: UInt8) {
        
    }
}
