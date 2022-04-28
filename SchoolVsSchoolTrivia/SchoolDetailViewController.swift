//
//  SchoolDetailViewController.swift
//  SchoolVsSchoolTrivia
//
//  Created by Aleksej Cupic on 4/27/22.
//

import UIKit
import GooglePlaces
import MapKit

class SchoolDetailViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dailyPercentageLabel: UILabel!
    @IBOutlet weak var overallPercentageLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var school: School!
    let regionDistance: CLLocationDegrees = 750.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        if school == nil {
//            school = School()
//        }
        setupMapView()
        updateUserInterface()
    }
    
    func setupMapView() {
        let region = MKCoordinateRegion(center: school.coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        mapView.setRegion(region, animated: true)
    }
    
    func updateMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(school)
        mapView.setCenter(school.coordinate, animated: false)
    }
    
    func updateUserInterface() {
        nameLabel.text = school.name
        addressLabel.text = school.address
        updateMap()
    }
}
