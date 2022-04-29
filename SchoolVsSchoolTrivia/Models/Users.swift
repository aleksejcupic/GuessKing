//
//  Users.swift
//  SchoolVsSchoolTrivia
//
//  Created by Aleksej Cupic on 4/29/22.
//

import Foundation
import Firebase
import FirebaseFirestore

class Users {
    var userArray: [User] = []
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
                let user = User(dictionary: document.data())
                user.documentID = document.documentID
                self.userArray.append(user)
            }
            completed()
        }
    }
}
