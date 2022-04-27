//
//  SchoolTableViewCell.swift
//  SchoolVsSchoolTrivia
//
//  Created by Aleksej Cupic on 4/27/22.
//

import UIKit

class SchoolTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dailyLabel: UILabel!
    @IBOutlet weak var overallLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
