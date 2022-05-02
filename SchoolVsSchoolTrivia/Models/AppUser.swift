//
//  User.swift
//  SchoolVsSchoolTrivia
//
//  Created by Aleksej Cupic on 4/29/22.
//

import Foundation
import Firebase
import FirebaseFirestore

class AppUser {
    var displayName: String
    var email: String
    var gamesPlayed: Int
    var avgGuesses: Double
    var userSince: Date
    var documentID: String
    
    var dictionary: [String: Any] {
        let timeIntervalDate = userSince.timeIntervalSince1970
        return ["displayName": displayName, "email": email, "gamesPlayed": gamesPlayed, "avgGuesses": avgGuesses, "userSince": timeIntervalDate, "documentID": documentID]
    }
    
    init(displayName: String, email: String, gamesPlayed: Int, avgGuesses: Double, userSince: Date, documentID: String) {
        self.displayName = displayName
        self.email = email
        self.gamesPlayed = gamesPlayed
        self.avgGuesses = avgGuesses
        self.userSince = userSince
        self.documentID = documentID
    }
    
    convenience init() {
        let displayName = Auth.auth().currentUser?.uid ?? ""
        let email = Auth.auth().currentUser?.email ?? ""
        let documentID = Auth.auth().currentUser?.uid ?? ""
        self.init(displayName: displayName, email: email, gamesPlayed: 0, avgGuesses: 0, userSince: Date(), documentID: documentID)
    }
    
    convenience init(user: User) {
        let displayName = user.displayName ?? ""
        let email = user.email ?? ""
        self.init(displayName: displayName, email: email, gamesPlayed: 0, avgGuesses: 0, userSince: Date(), documentID: user.uid)
    }
    
    convenience init(dictionary: [String: Any]) {
        let displayName = dictionary["displayName"] as! String? ?? ""
        let email = dictionary["email"] as! String? ?? ""
        let gamesPlayed = dictionary["gamesPlayed"] as! Int? ?? 0
        let avgGuesses = dictionary["avgGuesses"] as! Double? ?? 0.0
        let timeIntervalDate = dictionary["userSince"] as! TimeInterval? ?? TimeInterval()
        let userSince = Date(timeIntervalSince1970: timeIntervalDate)
        let documentID = dictionary["documentID"] as! String? ?? ""
        self.init(displayName: displayName, email: email, gamesPlayed: gamesPlayed, avgGuesses: avgGuesses, userSince: userSince, documentID: documentID)
    }
    
    func saveIfNewUser(completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        
        let userRef = db.collection("users").document(documentID)
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
            db.collection("users").document(self.documentID).setData(dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: \(error!.localizedDescription) could not save data for \(self.documentID)")
                    return completion(false)
                }
                return completion(true)
            }
        }
    }
}
