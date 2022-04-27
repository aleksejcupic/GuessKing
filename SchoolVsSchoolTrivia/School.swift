//
//  School.swift
//  SchoolVsSchoolTrivia
//
//  Created by Aleksej Cupic on 4/27/22.
//

import Foundation
import Firebase

class School {
    var name: String
    var address: String
    var dailyPercentage: Double
    var overallPercentge: Double
    var numberOfStudents: Int
    var firstUserID: String
    //var listOfStudents: [Student]
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["name": name, "address": address, "dailyPercentage": dailyPercentage, "overallPercentage": overallPercentge, "numberOfStudents": numberOfStudents, "firstUserID": firstUserID]
    }
    
    init(name: String, address: String, dailyPercentage: Double, overallPercentage: Double, numberOfStudents: Int, firstUserID: String, documentID: String) {
        self.name = name
        self.address = address
        self.dailyPercentage = dailyPercentage
        self.overallPercentge = overallPercentage
        self.numberOfStudents = numberOfStudents
        self.firstUserID = firstUserID
        self.documentID = documentID
    }
    
    convenience init() {
        self.init(name: "", address: "", dailyPercentage: 0, overallPercentage: 0, numberOfStudents: 0, firstUserID: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let name = dictionary["name"] as! String? ?? ""
        let address = dictionary["address"] as! String? ?? ""
//        let latitude = dictionary["latitude"] as! CLLocationDegrees? ?? 0.0
//        let longitude = dictionary["longitutde"] as! CLLocationDegrees? ?? 0.0
        let dailyPercentage = dictionary["dailyPercentage"] as! Double? ?? 0.0
        let overallPercentage = dictionary["overallPercentage"] as! Double? ?? 0.0
        let numberOfStudents = dictionary["numberOfStudents"] as! Int? ?? 0
        let firstUserID = dictionary["firstUserID"] as! String? ?? ""
        self.init(name: name, address: address, dailyPercentage: dailyPercentage, overallPercentage: overallPercentage, numberOfStudents: numberOfStudents, firstUserID: firstUserID, documentID: "")
    }
    
    func saveData(completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        // Grab the user ID
        guard let firstUserID = (Auth.auth().currentUser?.uid) else {
            print("ERROR: could not save data: not a valid firstUserID")
            return completion(false)
        }
        self.firstUserID = firstUserID
        // Create the dictionary representing the data we want to save
        let dataToSave: [String: Any] = self.dictionary
        // if we HAVE saved a record, we'll have an ID
        if self.documentID == "" { // Create new document via .addDocument
            var ref: DocumentReference? = nil // Firestore will create a new ID for us
            ref = db.collection("schools").addDocument(data: dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: adding document \(error!.localizedDescription)")
                    return completion(false)
                }
                self.documentID = ref!.documentID
                print("Added document: \(self.documentID)")
                completion(true)
            }
        } else { // else save to the existing document ID
            let ref = db.collection("schools").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: updating document \(error!.localizedDescription)")
                    return completion(false)
                }
                print("Updated document: \(self.documentID)")
                completion(true)
            }
        }
    }
}
