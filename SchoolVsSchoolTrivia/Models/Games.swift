//
//  Games.swift
//  SchoolVsSchoolTrivia
//
//  Created by Aleksej Cupic on 4/29/22.
//

import Foundation
import Firebase
import FirebaseFirestore

class Games {
    var gameArray: [Game] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(school: School, student: Student, completed: @escaping ()-> ()) {
        guard school.documentID != "" else {
            return
        }
        guard student.documentID != "" else {
            return
        }
        db.collection("schools").document(school.documentID).collection("students").document(student.documentID).collection("games").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print(" ERROR: adding snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.gameArray = [] // clean out to load new data
            // querySnapshot!.documents.count documents in the snapshot
            for document in querySnapshot!.documents {
                // make sure to have a dictionary initializer in the Spot class
                let game = Game(dictionary: document.data())
                game.documentID = document.documentID
                self.gameArray.append(game)
            }
            completed()
        }
    }
}
