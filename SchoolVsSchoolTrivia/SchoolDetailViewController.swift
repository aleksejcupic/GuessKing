//
//  SchoolDetailViewController.swift
//  SchoolVsSchoolTrivia
//
//  Created by Aleksej Cupic on 4/27/22.
//

import UIKit

class SchoolDetailViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dailyPercentageLabel: UILabel!
    @IBOutlet weak var overallPercentageLabel: UILabel!
    
    var school: School!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        if school == nil {
//            school = School()
//        }
        updateUserInterface()
    }
    
    func updateUserInterface() { // update when we arrive with new data
        nameLabel.text = school.name // ERROR FOR NOW
        addressLabel.text = school.address // ERROR FOR NOW
    }

}
