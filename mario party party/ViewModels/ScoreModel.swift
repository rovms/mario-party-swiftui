//
//  ViewModel.swift
//  mario party party
//
//  Created by Roman Bucher on 27/12/2023.
//

import Foundation
import Firebase

class ScoreModel: ObservableObject {
    @Published var scores = [Score]()
    
    let db = Firestore.firestore()
    
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
            for i in userModel.users.indices {
                if userModel.users[i].id == score.userId {
                    userModel.users[i].score = 0
                }
            }
        }
    }
    
    func delete(score: Score) {
        db.collection("scores").document(score.id).delete()
    }
    
    func getScoreFromFirestoreDoc(i: Int = -1, documentSnapshot: QueryDocumentSnapshot) -> Score {
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
