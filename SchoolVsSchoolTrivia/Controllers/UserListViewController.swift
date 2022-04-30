//
//  SchoolListViewController.swift
//  SchoolVsSchoolTrivia
//
//  Created by Aleksej Cupic on 4/27/22.
//

import UIKit

class UserListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    
    var users: AppUsers!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        users = AppUsers()
        users.loadData {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.sortBasedOnSegmentPressed()
        self.tableView.reloadData()
    }
    
    func sortBasedOnSegmentPressed() {
        switch sortSegmentedControl.selectedSegmentIndex {
        case 0:
            users.userArray.sort(by: {$0.displayName > $1.displayName})
        case 1:
            users.userArray.sort(by: {$0.gamesPlayed > $1.gamesPlayed})
        case 2:
            users.userArray.sort(by: {$0.avgGuesses < $1.avgGuesses})
        default:
            print("ERROR")
        }
        tableView.reloadData()
    }
    
    @IBAction func sortSegmentPressed(_ sender: UISegmentedControl) {
        sortBasedOnSegmentPressed()
    }
}

extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.userArray.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserTableViewCell
        cell.user = users.userArray[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
