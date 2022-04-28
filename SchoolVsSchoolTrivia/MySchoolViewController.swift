//
//  MySchoolViewController.swift
//  SchoolVsSchoolTrivia
//
//  Created by Aleksej Cupic on 4/27/22.
//

import UIKit
import GooglePlaces
import MapKit

class MySchoolViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var dailyLabel: UILabel!
    @IBOutlet weak var overallLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var school: School!
    let regionDistance: CLLocationDegrees = 750.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if school == nil {
            school = School()
        }
        setupMapView()
        updateUserInterface()
    }
    
    func setupMapView() {
        let region = MKCoordinateRegion(center: school.coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        mapView.setRegion(region, animated: true)
    }
    
    func updateUserInterface() {
        nameTextField.text = school.name
        addressTextField.text = school.address
        updateMap()
    }
    
    func updateMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(school)
        mapView.setCenter(school.coordinate, animated: true)
    }
    
    func updateFromInterface() { // update before saving data
        school.name = nameTextField.text!
        school.address = addressTextField.text!
    }
    
    func leaveViewOCntroller() {
        let isPresenting = presentingViewController is UINavigationController
        if isPresenting {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        updateFromInterface()
        school.saveData { (success) in
            if success {
                self.leaveViewOCntroller()
            } else {
                self.oneButtonAlert(title: "Save Failed", message: "Data could not save to the cloud")
            }
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewOCntroller()
    }
    @IBAction func lookupButtonPressed(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
    }
}

extension MySchoolViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        school.name = place.name ?? "Unknown Place"
        school.address = place.formattedAddress ?? "Unknown Address"
        school.coordinate = place.coordinate
        updateUserInterface()
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
