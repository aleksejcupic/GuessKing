//
//  Game.swift
//  SchoolVsSchoolTrivia
//
//  Created by Aleksej Cupic on 4/29/22.
//

import Foundation
import Firebase
import FirebaseFirestore

class Game {
    var userID: String
    var date: Date
    var correct: Int
    var documentID: String
    
    var dictionary: [String: Any] {
        let timeIntervalDate = date.timeIntervalSince1970
        return ["userID": userID, "date": timeIntervalDate, "correct": correct]
    }
    
    init(userID: String, date: Date, correct: Int, documentID: String) {
        self.userID = userID
        self.date = date
        self.correct = correct
        self.documentID = documentID
    }
    
    convenience init() {
        let userID = Auth.auth().currentUser?.uid ?? ""
        self.init(userID: userID, date: Date(), correct: 0, documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let userID = dictionary["userID"] as! String? ?? ""
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        let correct = dictionary["correct"] as! Int? ?? 0
        self.init(userID: userID, date: date, correct: correct, documentID: "")
    }
    
    func saveData(school: School, student: Student, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let dataToSave: [String: Any] = self.dictionary
        if self.documentID == "" {
            var ref: DocumentReference? = nil
            ref = db.collection("schools").document(school.documentID).collection("students").document(student.documentID).collection("games").addDocument(data: dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: adding document \(error!.localizedDescription)")
                    return completion(false)
                }
                self.documentID = ref!.documentID
                print("added document: \(self.documentID) to school \(school.documentID) and student \(student.documentID)")
                school.updatePercentages {
                    completion(true)
                }
                student.dailyCorrect = self.correct
                student.gamesPlayed += 1
            }
        } else {
            let ref = db.collection("schools").document(school.documentID).collection("students").document(student.documentID).collection("games").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: updating document \(error!.localizedDescription)")
                    return completion(false)
                }
                print("updated document: \(self.documentID) to school \(school.documentID) and student \(student.documentID)")
                school.updatePercentages {
                    completion(true)
                }
                student.dailyCorrect = self.correct
                student.gamesPlayed += 1
            }
        }
    }
}
