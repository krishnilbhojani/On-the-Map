//
//  AddLocationViewController.swift
//  On the Map
//
//  Created by Krishnil Bhojani on 17/05/20.
//  Copyright © 2020 Krishnil Bhojani. All rights reserved.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
        
    var address: String?
    var mediaUrl: String?
    var latitude: Double?
    var longitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addAnnotation()
    }
    
    func addAnnotation(){
        guard let latitude = latitude, let longitude = longitude else { return }
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = address
        
        mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 20000, longitudinalMeters: 20000)
        mapView.region = region
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func finishButton(_ sender: UIButton) {
        
        guard let address = address, let url = mediaUrl else { return }
        guard let latitude = latitude, let longitude = longitude else { return }
        
        let studentLocation = StudentLocationRequest(uniqueKey: OnTheMapAPI.Auth.userId, firstName: OnTheMapAPI.Auth.firstName, lastName: OnTheMapAPI.Auth.lastName, mapString: address, mediaURL: url, latitude: latitude, longitude: longitude)
        
        OnTheMapAPI.postStudentLocation(studentLocation: studentLocation) { (success) in
            if success{
                self.dismiss(animated: true, completion: nil)
            }else{
                self.showAlert(with: "Location Posting Failed")
            }
        }
    }
    
    func showAlert(with message: String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        show(alert, sender: self)
    }
    
}
