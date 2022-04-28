//
//  School.swift
//  SchoolVsSchoolTrivia
//
//  Created by Aleksej Cupic on 4/27/22.
//

import Foundation
import Firebase
import MapKit

class School: NSObject, MKAnnotation {
    var name: String
    var address: String
    var coordinate: CLLocationCoordinate2D
    var dailyPercentage: Double
    var overallPercentage: Double
    var numberOfStudents: Int
    var firstUserID: String
    var students: Students
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["name": name, "address": address, "latitude": latitude, "longitude": longitude, "dailyPercentage": dailyPercentage, "overallPercentage": overallPercentage, "numberOfStudents": numberOfStudents, "firstUserID": firstUserID, "students": students]
    }
    
    var latitude: CLLocationDegrees {
        return coordinate.latitude
    }
    
    var longitude: CLLocationDegrees {
        return coordinate.longitude
    }
    
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    var title: String? {
        return name
    }
    var subtitle: String? {
        return address
    }
    
    
    init(name: String, address: String, coordinate: CLLocationCoordinate2D, dailyPercentage: Double, overallPercentage: Double, numberOfStudents: Int, firstUserID: String, students: Students, documentID: String) {
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.dailyPercentage = dailyPercentage
        self.overallPercentage = overallPercentage
        self.numberOfStudents = numberOfStudents
        self.firstUserID = firstUserID
        self.students = students
        self.documentID = documentID
    }
    
    override convenience init() {
        self.init(name: "", address: "", coordinate: CLLocationCoordinate2D(), dailyPercentage: 0, overallPercentage: 0, numberOfStudents: 0, firstUserID: "", students: Students(), documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let name = dictionary["name"] as! String? ?? ""
        let address = dictionary["address"] as! String? ?? ""
        let latitude = dictionary["latitude"] as! Double? ?? 0.0
        let longitude = dictionary["longitude"] as! Double? ?? 0.0
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let dailyPercentage = dictionary["dailyPercentage"] as! Double? ?? 0.0
        let overallPercentage = dictionary["overallPercentage"] as! Double? ?? 0.0
        let numberOfStudents = dictionary["numberOfStudents"] as! Int? ?? 0
        let firstUserID = dictionary["firstUserID"] as! String? ?? ""
        let students = dictionary["students"] as! Students
        self.init(name: name, address: address, coordinate: coordinate, dailyPercentage: dailyPercentage, overallPercentage: overallPercentage, numberOfStudents: numberOfStudents, firstUserID: firstUserID, students: students, documentID: "")
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
    
    func updatePercentages(completed: @escaping() -> ()) {
        let db = Firestore.firestore()
        let studentsRef = db.collection("schools").document(documentID).collection("students")
        // get all students
        studentsRef.getDocuments { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: failed to get query snapshot of students for studentsRef \(studentsRef)")
                return completed()
            }
            var dailyTotal = 0.0
            var overallTotal = 0.0
            for document in querySnapshot!.documents {
                let studentDictionary = document.data()
                let daily = Double(studentDictionary["dailyCorrect"] as! Int? ?? 0) / 5.0
                dailyTotal += daily
                let overall = Double(studentDictionary["OverallCorrect"] as! Int? ?? 0) / 5.0
                overallTotal += overall
            }
            self.dailyPercentage = dailyTotal / Double(querySnapshot!.count)
            self.overallPercentage = overallTotal / Double(querySnapshot!.count)
            self.numberOfStudents = querySnapshot!.count
            let dataToSave = self.dictionary
            let schoolRef = db.collection("schools").document(self.documentID)
            schoolRef.setData(dataToSave) { (error) in
                if let error = error {
                    print("ERROR: updating document \(self.documentID) in school \(error.localizedDescription)")
                    completed()
                } else {
                    print("new daily percentage \(self.dailyPercentage)")
                    completed()
                }
            }
        }
    }
}
