//
//  UserTableViewCell.swift
//  SchoolVsSchoolTrivia
//
//  Created by Aleksej Cupic on 4/29/22.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var gamesPlayedLabel: UILabel!
    @IBOutlet weak var avgGuessesLabel: UILabel!
    
    var user: AppUser! {
        didSet {
            nameLabel.text = user.displayName
            gamesPlayedLabel.text = "\(user.gamesPlayed)"
            avgGuessesLabel.text = "\(user.avgGuesses)"
        }
    }
}
