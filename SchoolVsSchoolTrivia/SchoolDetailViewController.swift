//
//  SchoolDetailViewController.swift
//  SchoolVsSchoolTrivia
//
//  Created by Aleksej Cupic on 4/27/22.
//

import UIKit
import GooglePlaces
import MapKit
import Contacts

class SchoolDetailViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dailyPercentageLabel: UILabel!
    @IBOutlet weak var overallPercentageLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var school: School!
    let regionDistance: CLLocationDegrees = 750.0
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getLocation()
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

extension SchoolDetailViewController: CLLocationManagerDelegate {
    func getLocation() {
        // Creating a CLLocationManager will automatically check authorization
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func handleAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            self.oneButtonAlert(title: "Location services denied", message: "It may be that parental controls are restricting location use in this app.")
        case .denied:
            showAlertToPrivacySettings(title: "User has not authorized location services", message: "Select 'Settings' below to enable device settings and enable location services for this app.")
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            print("DEVELOPER ALERT: Unknown case of status in handleAuthorizationStatus \(status)")
        }
    }
    
    func showAlertToPrivacySettings(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            print("Something went wrong getting the UIApplication.openSettingsURLString")
            return
        }
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (value) in
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("👮‍♀️👮‍♀️ Checking authorization status")
        handleAuthorizationStatus(status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last ?? CLLocation()
        print("🗺 Current location is \(currentLocation.coordinate.latitude),\(currentLocation.coordinate.longitude)")
        var name = ""
        var address = ""
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            if error != nil {
                print("😡 ERROR: retrieving place. \(error!.localizedDescription)")
            }
            if placemarks != nil {
                // get the first placemark
                let placemark = placemarks?.last
                // assign placemark to locationName
                name = placemark?.name ?? "Name Unknown"
                if let postalAddress = placemark?.postalAddress {
                    address = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
                }
            }
//            else {
//                print("😡 ERROR: retrieving placemark.")
//            }
            // if there is no spot data, make device location the Spot
            if self.school.name == "" && self.school.address == "" {
                self.school.name = name
                self.school.address = address
                self.school.coordinate = currentLocation.coordinate
            }
            self.mapView.userLocation.title = name
            self.mapView.userLocation.subtitle = address.replacingOccurrences(of: "\n", with: ", ")
            self.updateUserInterface()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR: \(error.localizedDescription). Failed to get device location.")
    }
}
