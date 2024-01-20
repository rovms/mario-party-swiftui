//
//  ViewModel.swift
//  mario party party
//
//  Created by Roman Bucher on 27/12/2023.
//

import Foundation
import Firebase

enum DataError: Error {
    case missingScore
    case missingDate
}

class ScoreModel: ObservableObject {
    @Published var scores = [Score]()
    
    let db = Firestore.firestore()
    
    func getScores() {
        db.collection("scores").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    DispatchQueue.main.async {
                        self.scores = snapshot.documents.map { documentSnapshot in
                            return self.getScoreFromFirestoreDoc(documentSnapshot: documentSnapshot)
                        }
                    }
                }
            }
        }
    }
    
    func getUpdatedScores() {
        db.collection("scores").whereField("date", isGreaterThan: Date()).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("error fetching snapshots (listener)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                let document = diff.document
                if (diff.type == .added) {
                    self.scores.append(self.getScoreFromFirestoreDoc(documentSnapshot: document))
                    print("New score: \(document.data())")
                }
                if (diff.type == .modified) {
                    //TODO:
                    print("Modified score: \(document.data())")
                }
                if (diff.type == .removed) {
                    //TODO:
                    let removedIndex = self.scores.firstIndex(where: { $0.id == document.documentID})!
                    self.scores.remove(at: removedIndex)
                    print("Removed score: \(document.data())")
                }
            }
        }
    }
    
    func addScores(score: Score, userModel: UserModel = UserModel()) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        let ref = db.collection("scores").addDocument(data: ["value": score.value, "userId": score.userId, "date": score.date, "game": score.game])
        ref.getDocument { document, error in
            if error == nil {
                if let document = document, document.exists {
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("DONE ADDING SCORE")
            for i in userModel.users.indices {
                if userModel.users[i].id == score.userId {
                    userModel.users[i].score = 0
                }
            }
        }
    }
    
    func getScoresByUserId(userId: String) -> [Score] {
        print("getScoresByUserId")
        let filtered = scores.filter { score in
            if score.userId == userId {
                return true
            }
            return false
        }
        print(userId)
        print(filtered)
        return filtered
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
}
