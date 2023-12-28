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
                        self.scores = snapshot.documents.map { score in
                            let value = score["value"]
                            let date = score["date"]
                            if (value == nil) {
                                print("mising score")
                            }
                            if (date == nil) {
                                print("missing date")
                            }
                            return Score(
                                id: score.documentID,
                                value: score["value"] as? Int ?? 0,
                                date: score["date"] as? Date ?? Date(),
                                userId: score["userId"] as? String ?? ""
                            )
                        }
                    }
                }
            }
        }
    }
    
    func addScores(score: Score) {
        do {
            let _ = try db.collection("scores").addDocument(data: ["value": score.value, "userId": score.userId, "date": score.date])
        } catch {
            print(error)
        }
    }
}
