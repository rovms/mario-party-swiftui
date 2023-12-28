//
//  ViewModel.swift
//  mario party party
//
//  Created by Roman Bucher on 24/12/2023.
//

import Foundation
import Firebase

class UserModel: ObservableObject {
    @Published var users = [User]()
    
    func getUsers() {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    DispatchQueue.main.async {
                        self.users = snapshot.documents.map { user in
                            print(snapshot.documents)
                            return User(
                                id: user.documentID,
                                name: user["name"] as? String ?? "",
                                score: 0)
                        }
                    }
                }
            }
        }
    }
    
    func updateScore(userId: String, newScore: Int) {
        for i in 0..<users.count {
            if users[i].id == userId {
                users[i].score = newScore
            }
        }
    }
}
