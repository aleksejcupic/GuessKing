//
//  MySchoolViewController.swift
//  SchoolVsSchoolTrivia
//
//  Created by Aleksej Cupic on 4/27/22.
//

import UIKit
import GooglePlaces

class MySchoolViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var dailyLabel: UILabel!
    @IBOutlet weak var overallLabel: UILabel!
    
    var school: School!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if school == nil {
            school = School()
        }
    }
    
    func updateUserInterface() { // update when we arrive with new data
        nameTextField.text = school.name // ERROR FOR NOW
        addressTextField.text = school.address // ERROR FOR NOW
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
        print("Place name: \(place.name)")
        print("Place ID: \(place.placeID)")
        print("Place attributions: \(place.attributions)")
        school.name = place.name ?? "Unknown Place"
        school.address = place.formattedAddress ?? "Unknown Address"
        print("Coordinates = \(place.coordinate)")
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
