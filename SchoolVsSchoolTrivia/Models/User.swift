//
//  User.swift
//  SchoolVsSchoolTrivia
//
//  Created by Aleksej Cupic on 4/29/22.
//

import Foundation
import Firebase
import FirebaseFirestore

class User {
    var userID: String
    var name: String
    var email: String
    var userSince: Date
    var games: Games
    var documentID: String
    
    var dictionary: [String: Any] {
        let timeIntervalDate = userSince.timeIntervalSince1970
        return ["userID": userID, "name": name, "email": email, "userSince": timeIntervalDate, "games": games]
    }
    
    init(userID: String, name: String, email: String, userSince: Date, games: Games, documentID: String) {
        self.userID = userID
        self.name = name
        self.email = email
        self.userSince = userSince
        self.games = games
        self.documentID = documentID
    }
    
    convenience init(user: User) {
        let userID = Auth.auth().currentUser?.uid ?? ""
        let name = user.name
        let email = user.email
        let userSince = user.userSince
        let games = user.games
        self.init(userID: userID, name: name, email: email, userSince: userSince, games: games, documentID: user.documentID)
    }
    
    convenience init(dictionary: [String: Any]) {
        let userID = dictionary["userID"] as! String? ?? ""
        let name = dictionary["name"] as! String? ?? ""
        let email = dictionary["email"] as! String? ?? ""
        let timeIntervalDate = dictionary["dateCreated"] as! TimeInterval? ?? TimeInterval()
        let userSince = Date(timeIntervalSince1970: timeIntervalDate)
        let games = dictionary["games"] as! Games? ?? Games()
        self.init(userID: userID, name: name, email: email, userSince: userSince, games: games, documentID: "")
    }
    
    func saveIfNewUser(school: School, completion: @escaping (Bool) -> ()) {
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
