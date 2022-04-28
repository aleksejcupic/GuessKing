//
//  SchoolTableViewCell.swift
//  SchoolVsSchoolTrivia
//
//  Created by Aleksej Cupic on 4/27/22.
//

import UIKit
import CoreLocation

class SchoolTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dailyLabel: UILabel!
    @IBOutlet weak var overallLabel: UILabel!
    
    var currentLocation: CLLocation!
    var school: School! {
        didSet {
            nameLabel.text = school.name
            dailyLabel.text = "\(school.dailyPercentage)"
            overallLabel.text = "\(school.overallPercentage)"
            guard let currentLocation = currentLocation else {
                distanceLabel.text = "-.-"
                return
            }
            let distanceInMeters = school.location.distance(from: currentLocation)
            let distanceInMiles = ((distanceInMeters * 0.00062137) * 10).rounded() / 10
            distanceLabel.text = "\(distanceInMiles)"
        }
    }
}
