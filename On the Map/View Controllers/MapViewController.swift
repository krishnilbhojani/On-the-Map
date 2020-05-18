//
//  MapViewController.swift
//  On the Map
//
//  Created by Krishnil Bhojani on 15/05/20.
//  Copyright © 2020 Krishnil Bhojani. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController{
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locations = [StudentLocationResponse]()

    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
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
    
}

extension MapViewController: MKMapViewDelegate{
    func loadLocations(){
        OnTheMapAPI.getStudentsLocation { (studentInfo, error) in
            if let studentInfo = studentInfo{
                self.locations = studentInfo
                self.mapView.removeAnnotations(self.annotations)
                self.annotations.removeAll()
                self.addAnnotations()
            }
        }
    }

    func addAnnotations(){
        for studentInfo in locations {

            let lat = CLLocationDegrees(studentInfo.latitude)
            let long = CLLocationDegrees(studentInfo.longitude)

            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)

            let first = studentInfo.firstName
            let last = studentInfo.lastName
            let mediaURL = studentInfo.mediaURL

            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL

            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil{
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }else{
            pinView!.annotation = annotation
        }

        return pinView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView{
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle!, let url = URL(string: toOpen){
                app.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
