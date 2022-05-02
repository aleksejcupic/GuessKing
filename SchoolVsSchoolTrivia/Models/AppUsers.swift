//
//  Users.swift
//  SchoolVsSchoolTrivia
//
//  Created by Aleksej Cupic on 4/29/22.
//

import Foundation
import Firebase
import FirebaseFirestore

class AppUsers {
    var userArray: [AppUser] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping ()-> ()) {
        db.collection("users").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print(" ERROR: adding snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.userArray = [] // clean out to load new data
            // querySnapshot!.documents.count documents in the snapshot
            for document in querySnapshot!.documents {
                // make sure to have a dictionary initializer in the Spot class
                let user = AppUser(dictionary: document.data())
                user.documentID = document.documentID
                self.userArray.append(user)
            }
            completed()
        }
    }
    
    func loadWin(guessCount: Int) {
        let db = Firestore.firestore()
        db.collection("users").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: adding snapshot listener \(error!.localizedDescription)")
                return
            }
            for document in querySnapshot!.documents {
                let user = AppUser(dictionary: document.data())
                user.documentID = document.documentID
                user.gamesPlayed += 1
                user.avgGuesses = Double(((user.avgGuesses * Double(user.gamesPlayed)) + Double(guessCount)) / Double((user.gamesPlayed + 1)))
                let userRef = db.collection("users").document(user.documentID)
                userRef.getDocument { (document, error) in
                    guard document?.exists == false else {
                        print("document for user \(user.documentID) exists")
                        let dataToSave: [String: Any] = user.dictionary
                        db.collection("users").document(user.documentID).setData(dataToSave) { (error) in
                            guard error == nil else {
                                print("ERROR: \(error!.localizedDescription) could not save data for \(user.documentID)")
                                return
                            }
                        }
                        return
                    }
                }
            }
        }
        //    return
    }
    //return
    //}
    //}
}
