//
//  ListViewController.swift
//  On the Map
//
//  Created by Krishnil Bhojani on 15/05/20.
//  Copyright © 2020 Krishnil Bhojani. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {

    let reuseId = "CellId"
    
    var locations = [StudentLocationResponse]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseId)
        
        loadLocations()
    }

    @IBAction func addPinButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToFindLocationVC", sender: self)
    }
    
    @IBAction func refreshButton(_ sender: UIBarButtonItem) {
        loadLocations()
    }
    
    @IBAction func logoutButton(_ sender: UIBarButtonItem) {
        OnTheMapAPI.deleteSession { (success, error) in
            if success{
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func loadLocations(){
        OnTheMapAPI.getStudentsLocation { (studentInfo, error) in
            if let studentInfo = studentInfo{
                self.locations = studentInfo
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath)
        cell.imageView?.image = #imageLiteral(resourceName: "icon_pin")
        let studentInfo = locations[indexPath.row]
        cell.textLabel?.text = "\(studentInfo.firstName) \(studentInfo.lastName)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = URL(string: locations[indexPath.row].mediaURL) else { return }
        UIApplication.shared.open(url, options: [:]) { (_) in
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }

}
