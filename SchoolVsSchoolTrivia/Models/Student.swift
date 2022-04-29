//
//  Student.swift
//  SchoolVsSchoolTrivia
//
//  Created by Aleksej Cupic on 4/28/22.
//

import Foundation
import Firebase
import FirebaseFirestore

class Student {
    var userID: String
    var name: String
    var gamesPlayed: Int
    var dailyCorrect: Int
    var overallCorrect: Double
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["userID": userID, "name": name, "gamesPlayed": gamesPlayed, "dailyCorrect": dailyCorrect, "overallCorrect": overallCorrect]
    }
    
    init(userID: String, name: String, gamesPlayed: Int, dailyCorrect: Int, overallCorrect: Double, documentID: String) {
        self.userID = userID
        self.name = name
        self.gamesPlayed = gamesPlayed
        self.dailyCorrect = dailyCorrect
        self.overallCorrect = overallCorrect
        self.documentID = documentID
    }
    
    convenience init() {
        self.init(userID: "", name: "", gamesPlayed: 0, dailyCorrect: 0, overallCorrect: 0.0, documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let userID = dictionary["userID"] as! String? ?? ""
        let name = dictionary["name"] as! String? ?? ""
        let gamesPlayed = dictionary["gamesPlayed"] as! Int? ?? 0
        let dailyCorrect = dictionary["dailyCorrect"] as! Int? ?? 0
        let overallCorrect = dictionary["overallCorrect"] as! Double? ?? 0.0
        let documentID = dictionary["documentID"] as! String? ?? ""
        self.init(userID: userID, name: name, gamesPlayed: gamesPlayed, dailyCorrect: dailyCorrect, overallCorrect: overallCorrect, documentID: documentID)
    }
    
    func saveData(school: School, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        
        // Create dictionary representing data to save
        let dataToSave: [String: Any] = self.dictionary
        // if we HAVE saved a record, we'll have an ID
        if self.documentID == "" { // Create new document via .addDocument
            var ref: DocumentReference? = nil // Firestore will create a new ID for us
            ref = db.collection("schools").document(school.documentID).collection("students").addDocument(data: dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: adding document \(error!.localizedDescription)")
                    return completion(false)
                }
                self.documentID = ref!.documentID
                print("Added document: \(self.documentID) to school: \(school.documentID)")
                completion(true)
            }
        } else { // else save to the existing document ID
            let ref = db.collection("schools").document(school.documentID).collection("students").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: updating document \(error!.localizedDescription)")
                    return completion(false)
                }
                print("Updated document: \(self.documentID) to school: \(school.documentID)")
                completion(true)
            }
        }
    }
}
