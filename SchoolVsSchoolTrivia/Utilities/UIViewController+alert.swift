//
//  UIViewController+alert.swift
//  ToDo List
//
//  Created by John Gallaugher on 2/27/20.
//  Copyright © 2020 John Gallaugher. All rights reserved.
//

import UIKit

extension UIViewController {
    func oneButtonAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
