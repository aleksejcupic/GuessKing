//
//  SchoolListViewController.swift
//  SchoolVsSchoolTrivia
//
//  Created by Aleksej Cupic on 4/27/22.
//

import UIKit

class SchoolListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    
    var schools: Schools!
    
    //    var schools = ["Boston College", "Harvard University", "Northeastern University", "Tufts University", "Massachuesetts Institute of Technology", "University of Massachuesetts Boston", "Suffolk University", "Emerson College", "etc."]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        schools = Schools()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        schools.loadData {
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "ShowDetail" {
            let destination = segue.destination as! SchoolDetailViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.school = schools.schoolArray[selectedIndexPath.row]
        }
    }
}

extension SchoolListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schools.schoolArray.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SchoolTableViewCell
        cell.nameLabel?.text = schools.schoolArray[indexPath.row].name
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
