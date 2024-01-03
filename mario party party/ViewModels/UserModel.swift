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
    @Published var scores = [Score]()
    @Published var receivedUsers = false
    var scoreModel = ScoreModel()
    
    func getUsers() {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    DispatchQueue.main.async {
                        self.users = snapshot.documents.map { userDocument in
                            var user = self.getUserFromFirestoreDoc(documentSnapshot: userDocument)
                            db.collection("users").document(userDocument.documentID).collection("scores").getDocuments { scoreSnapshot, scoreError in
                                if scoreError == nil {
                                    if let scoreSnapshot = scoreSnapshot {
                                        DispatchQueue.main.async {
                                            scoreSnapshot.documents.forEach { score in
                                                user.scores.append(self.scoreModel.getScoreFromFirestoreDoc(documentSnapshot: score))
                                            }
                                        }
                                    }
                                }
                            }
                            return user
                        }
                    }
                }
            }
        }
        
        print(self.users)
    }
    
    
    func getData() {
        let group = DispatchGroup()
        
        let db = Firestore.firestore()
        group.enter() // users
        group.enter() // scores

        db.collection("users").getDocuments { userSnapshot, userError in
            if userError == nil {
                if let userSnapshot = userSnapshot {
                    DispatchQueue.main.async {
                        self.users = userSnapshot.documents.map { userDocument in
                            return self.getUserFromFirestoreDoc(documentSnapshot: userDocument)
                        }
                        group.leave()
                    }
                }
            }
        }
         
         db.collection("scores").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    DispatchQueue.main.async {
                        self.scores = snapshot.documents.map { scoreDocument in
                            return self.getScoreFromFirestoreDoc(documentSnapshot: scoreDocument)
                        }
                        group.leave()
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            print("--- DONE ---")
            print(self.users)
            print(self.scores)
            self.scores.forEach { score in
                for i in self.users.indices {
                    if score.userId == self.users[i].id {
                        self.users[i].scores.append(score)
                    }
                }
            }
            
            self.users.forEach { user in
                print("cumulative: " + user.name)
                print(user.cumulativeScores)
            }
        }
    }
    
    func getUser(userId: String) -> User {
        return self.users.first(where: { user in
            user.id == userId
        }) ?? User()
    }
    
    func updateScore(userId: String, newScore: Int) {
        for i in 0..<users.count {
            if users[i].id == userId {
                users[i].score = newScore
            }
        }
    }
    
    func getUserFromFirestoreDoc(documentSnapshot: QueryDocumentSnapshot) -> User {
            return User(
                id: documentSnapshot.documentID,
                name: documentSnapshot["name"] as? String ?? "",
                score: 0,
                scores: [Score]()
            )
    }
    
    func getScoreFromFirestoreDoc(documentSnapshot: QueryDocumentSnapshot) -> Score {
           return  Score(
                id: documentSnapshot.documentID,
                value: documentSnapshot["value"] as? Int ?? 0,
                date: documentSnapshot["date"] as? Date ?? Date(),
                userId: documentSnapshot["userId"] as? String ?? "",
                game: documentSnapshot["game"] as? String ?? ""
            )
    }
    
    func resetScore(userId: String) {
        for i in self.users.indices {
            if self.users[i].id == userId {
                self.users[i].score = 0
            }
        }
    }
}
