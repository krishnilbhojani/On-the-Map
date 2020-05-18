//
//  FindLocationViewController.swift
//  On the Map
//
//  Created by Krishnil Bhojani on 17/05/20.
//  Copyright © 2020 Krishnil Bhojani. All rights reserved.
//

import UIKit
import CoreLocation

class FindLocationViewController: UIViewController {
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var linkTestField: UITextField!
        
    var latitude: Double?
    var longitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findButton(_ sender: UIButton) {
        guard let address = addressTextField.text else { return }
        performForwardGeocoding(with: address) { (latitude, longitude) in
            self.latitude = latitude
            self.longitude = longitude
            self.performSegue(withIdentifier: "goToAddLocationVC", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as? AddLocationViewController
        destinationVC?.address = addressTextField.text
        destinationVC?.mediaUrl = linkTestField.text
        destinationVC?.latitude = latitude
        destinationVC?.longitude = longitude
    }
    
    func performForwardGeocoding(with address: String, completion: @escaping (Double, Double) -> ()){
        CLGeocoder().geocodeAddressString(address) { (placemarks, error) in
            if let error = error{
                print(error)
                return
            }
            if let placemarks = placemarks, let firstPlaceMark = placemarks.first, placemarks.count > 0 && firstPlaceMark.location != nil{
                guard let latitude = firstPlaceMark.location?.coordinate.latitude, let longitude = firstPlaceMark.location?.coordinate.longitude else { return }
                completion(latitude, longitude)
            }
        }
    }
    
}
