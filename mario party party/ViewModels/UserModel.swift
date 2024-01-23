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
        
        db.collection("scores").order(by: "date").getDocuments { snapshot, error in
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
            
            //TODO: Improve logic, as this assumes that there are always exactly 4 scores per game (4 players)
            for si in self.scores.indices {
                for ui in self.users.indices {
                    if self.scores[si].userId == self.users[ui].id {
                        self.users[ui].scores.append(self.scores[si])
                    }
                }
            }
        }
    }
    
    func getUpdatedScores() {
        let db = Firestore.firestore()
        db.collection("scores").whereField("date", isGreaterThan: Date()).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                return
            }
            snapshot.documentChanges.forEach { diff in
                let document = diff.document
                if (diff.type == .added) {
                    print("added score")
                    self.scores.append(self.getScoreFromFirestoreDoc(documentSnapshot: document))
                }
                if (diff.type == .modified) {
                    print("modified score")
                }
            }
        }
        
        db.collection("scores").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                return
            }
            snapshot.documentChanges.forEach { diff in
                let document = diff.document
                if (diff.type == .removed) {
                    print("removed score")
                    self.scores.removeAll(where: {
                        $0.id == document.documentID
                    })
                }
            }
        }
    }
    
    func scoresGroupedByDate() -> [Int: [Score]] {
        var ret: [Int: [Score]] = [1: [self.scores[0]]]
        var currentGroup = 1
        for i in self.scores.indices {
            if i != 0 {
                if self.scores[i].date == self.scores[i-1].date {
                    ret[currentGroup]?.append(self.scores[i])
                } else {
                    currentGroup = currentGroup + 1
                    ret[currentGroup] = [self.scores[i]]
                }
            }
        }
        return ret
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
        let ts = documentSnapshot["date"] as? Timestamp ?? Timestamp()
        return  Score(
            id: documentSnapshot.documentID,
            value: documentSnapshot["value"] as? Int ?? 0,
            date: ts.dateValue(),
            userId: documentSnapshot["userId"] as? String ?? "",
            game: documentSnapshot["game"] as? String ?? ""
        )
    }
}
