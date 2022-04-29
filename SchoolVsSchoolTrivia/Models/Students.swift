//
//  Students.swift
//  SchoolVsSchoolTrivia
//
//  Created by Aleksej Cupic on 4/28/22.
//

import Foundation
import Firebase
import FirebaseFirestore

class Students {
    var studentArray: [Student] = []
    
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(school: School, completed: @escaping () ->()) {
        guard school.documentID != "" else {
            return
        }
        db.collection("schools").document(school.documentID).collection("students").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: adding snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.studentArray = []
            for document in querySnapshot!.documents {
                let student = Student(dictionary: document.data())
                school.documentID = document.documentID
                self.studentArray.append(student)
            }
            completed()
        }
    }
}
