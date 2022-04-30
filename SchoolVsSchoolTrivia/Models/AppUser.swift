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
    
    
//    var db: Firestore!
//
//    init() {
//        db = Firestore.firestore()
//    }
    
    var dictionary: [String: Any] {
        let timeIntervalDate = userSince.timeIntervalSince1970
        return ["displayName": displayName, "email": email, "gamesPlayed": gamesPlayed, "avgGuesses": avgGuesses, "userSince": timeIntervalDate]
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
        let email = Auth.auth().currentUser?.email ?? "unknown email"
        self.init(displayName: displayName, email: email, gamesPlayed: 0, avgGuesses: 0, userSince: Date(), documentID: "")
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
        self.init(displayName: displayName, email: email, gamesPlayed: gamesPlayed, avgGuesses: avgGuesses, userSince: userSince, documentID: "")
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
    
//    func saveData(completion: @escaping (Bool) -> ()) {
//        let db = Firestore.firestore()
//        let userRef = db.collection("users").document(documentID)
//        userRef.getDocument { (document, error) in
//            guard error == nil else {
//                print("ERROR: could not access document for \(self.documentID)")
//                return completion(false)
//            }
//            let dataToSave: [String: Any] = self.dictionary
//            db.collection("users").document(self.documentID).setData(dataToSave) { (error) in
//                guard error == nil else {
//                    print("ERROR: \(error!.localizedDescription) could not save data for \(self.documentID)")
//                    return completion(false)
//                }
//                return completion(true)
//            }
//        }
//    }
    
//    func loadData(completed: @escaping ()-> ()) {
//        db.collection("users").addSnapshotListener { (querySnapshot, error) in
//            guard error == nil else {
//                print(" ERROR: adding snapshot listener \(error!.localizedDescription)")
//                return completed()
//            }
//            self.user = AppUser() // clean out to load new data
//            // querySnapshot!.documents.count documents in the snapshot
//            for document in querySnapshot!.documents {
//                // make sure to have a dictionary initializer in the Spot class
//                let review = Review(dictionary: document.data())
//                review.documentID = document.documentID
//                self.reviewArray.append(review)
//            }
//            completed()
//        }
//    }
    
    
    // OLD VERSION
    
//    func loadData(user: User, completed: @escaping (Bool) -> ()) {
//        var user = AppUser()
//        let db = Firestore.firestore()
//        db.collection("users").getDocuments { (querySnapshot, error) in
//            if error == nil {
//                DispatchQueue.main.async {
//                    self.user = querySnapshot.documents.map {
//                        dictionary in return AppUser(displayName: dictionary["displayName"] as! String? ?? "", email: dictionary["email"] as! String? ?? "", gamesPlayed: dictionary["gamesPlayed"] as! Int? ?? 0, avgGuesses: dictionary["avgGuesses"] as! Double? ?? 0.0, userSince: dictionary["userSince"] as! Date? ?? Date(), documentID: dictionary.documentID)
//                    }
//                }
//            } else {
//                print("ERROR: adding snapshot listener \(error!.localizedDescription)")
//                return completed(false)
//            }
//        }
//    }
}

