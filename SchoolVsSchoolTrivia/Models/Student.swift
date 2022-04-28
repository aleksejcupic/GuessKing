//
//  Student.swift
//  SchoolVsSchoolTrivia
//
//  Created by Aleksej Cupic on 4/28/22.
//

import Foundation
import Firebase

class Student {
    var name: String
    var email: String
    var userSince: Date
    var gamesPlayed: Int
    var dailyCorrect: Int
    var overallCorrect: Double
    var games: [Date: Int]
    var userID: String
    var documentID: String
    
    var dictionary: [String: Any] {
        let timeIntervalDate = userSince.timeIntervalSince1970
        return ["name": name, "email": email, "userSince": timeIntervalDate, "gamesPlayed": gamesPlayed, "dailyCorrect": dailyCorrect, "overallCorrect": overallCorrect, "games": games, "userID": userID]
    }
    
    init(name: String, email: String, userSince: Date, gamesPlayed: Int, dailyCorrect: Int, overallCorrect: Double, games: [Date: Int], userID: String, documentID: String) {
        self.name = name
        self.email = email
        self.userSince = userSince
        self.gamesPlayed = gamesPlayed
        self.dailyCorrect = dailyCorrect
        self.overallCorrect = overallCorrect
        self.games = games
        self.userID = userID
        self.documentID = documentID
    }
    
    convenience init() {
        let userID = Auth.auth().currentUser?.uid ?? ""
        self.init(name: "", email: "", userSince: Date(), gamesPlayed: 0, dailyCorrect: 0, overallCorrect: 0.0, games: [:], userID: userID, documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let name = dictionary["name"] as! String? ?? ""
        let email = dictionary["email"] as! String? ?? ""
        let timeIntervalDate = dictionary["dateCreated"] as! TimeInterval? ?? TimeInterval()
        let userSince = Date(timeIntervalSince1970: timeIntervalDate)
        let gamesPlayed = dictionary["gamesPlayed"] as! Int? ?? 0
        let dailyCorrect = dictionary["dailyCorrect"] as! Int? ?? 0
        let overallCorrect = dictionary["overallCorrect"] as! Double? ?? 0.0
        let games = dictionary["games"] as! [Date: Int]? ?? [Date(): 0]
        let userID = dictionary["userID"] as! String? ?? ""
        let documentID = dictionary["documentID"] as! String? ?? ""
        self.init(name: name, email: email, userSince: userSince, gamesPlayed: gamesPlayed, dailyCorrect: dailyCorrect, overallCorrect: overallCorrect, games: games, userID: userID, documentID: documentID)
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
    
    func saveIfNewUser(completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        
        let userRef = db.collection("schools").document(school.documentID).collection("students").document(documentID)
        userRef.getDocument { (document, error) in
            guard error == nil else {
                print("ERROR: could not access docment for \(self.documentID)")
                return completion(false)
            }
            guard document?.exists == false else {
                print("document for user \(self.documentID) exists")
                return completion(true)
            }
            let dataToSave: [String: Any] = self.dictionary
            db.collection("schools").document(school.documentID).collection("students").document(self.documentID).setData(dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: \(error!.localizedDescription) could not save data for \(self.documentID)")
                    return completion(false)
                }
                return completion(true)
            }
        }
    }
}

