//
//  Schools.swift
//  SchoolVsSchoolTrivia
//
//  Created by Aleksej Cupic on 4/27/22.
//

import Foundation
import Firebase

class Schools {
    var schoolArray: [School] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()) {
        db.collection("schools").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.schoolArray = []
            // there are querySnapshot!.documents.count in the schools snapshot
            for document in querySnapshot!.documents {
                // you'll have to be sure you've created an initializer in the singular class that accepts a dictionary
                let school = School(dictionary: document.data())
                school.documentID = document.documentID
                self.schoolArray.append(school)
            }
            completed()
        }
    }
}
