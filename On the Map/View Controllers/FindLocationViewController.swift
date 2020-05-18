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
    @IBOutlet weak var findButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var latitude: Double?
    var longitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addressTextField.delegate = self
        linkTestField.delegate = self
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
        setLoadingState(to: true)
        performForwardGeocoding(with: address) { (latitude, longitude) in
            self.latitude = latitude
            self.longitude = longitude
            self.setLoadingState(to: false)
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
            if let _ = error{
                self.showAlert(with: "Invalid Address, Try to format your address as 'City, State'")
                self.setLoadingState(to: false)
                return
            }
            if let placemarks = placemarks, let firstPlaceMark = placemarks.first, placemarks.count > 0 && firstPlaceMark.location != nil{
                guard let latitude = firstPlaceMark.location?.coordinate.latitude, let longitude = firstPlaceMark.location?.coordinate.longitude else { return }
                completion(latitude, longitude)
            }
        }
    }
    
    func setLoadingState(to isLoading: Bool){
        if isLoading {
            activityIndicator.startAnimating()
            addressTextField.isEnabled = false
            linkTestField.isEnabled = false
            findButton.isEnabled = false
        }else{
            activityIndicator.stopAnimating()
            addressTextField.isEnabled = true
            linkTestField.isEnabled = true
            findButton.isEnabled = true
        }
    }
    
    func showAlert(with message: String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}

extension FindLocationViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
