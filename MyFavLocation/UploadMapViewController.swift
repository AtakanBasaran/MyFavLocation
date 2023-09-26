//
//  UploadMapViewController.swift
//  MyFavLocation
//
//  Created by Atakan Başaran on 25.09.2023.
//

import UIKit
import MapKit
import CoreLocation
import ParseCore

class UploadMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var annotationTitle = ""
    var annotationSubtitle = ""
    var chosenComment = ""
    var chosenImage : UIImage?
    var chosenLatitude : Double?
    var chosenLongitude : Double?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()//get user location at the begining
        
        
        let gestureRecognizerMap = UILongPressGestureRecognizer(target: self, action: #selector(PickLocation(gestureRecognizer:)))
        gestureRecognizerMap.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecognizerMap)

    }
    
    @objc func saveButton() { //Creating class and its object in the Parse
        
        let place = PFObject(className: "Place")
        let imageData = chosenImage?.jpegData(compressionQuality: 0.5)
        if let imageData = imageData {
            let parseImage = PFFileObject(name: "Image.jpg", data: imageData)
            
            place["userID"] = PFUser.current()
            place["PlaceImage"] = parseImage
            place["Comment"] = chosenComment
            place["PlaceName"] = annotationTitle
            place["Type"] = annotationSubtitle
            place["Longitude"] = chosenLongitude
            place["Latitude"] = chosenLatitude
            
            place.saveInBackground { success, error in
                if error != nil {
                    self.ErrorAlert(title: "Error!", message: error?.localizedDescription ?? "Error!")
                } else {
                    self.performSegue(withIdentifier: "toMainVC", sender: nil)
                    
                }
            }

        }
        
    }
    
    @objc func PickLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        locationManager.stopUpdatingLocation()
        
        if gestureRecognizer.state == .began {
            let touchedLocationPoint = gestureRecognizer.location(in: mapView)
            let touchedCoordinate = mapView.convert(touchedLocationPoint, toCoordinateFrom: mapView)
            chosenLatitude = touchedCoordinate.latitude
            chosenLongitude = touchedCoordinate.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinate
            annotation.title = annotationTitle
            annotation.subtitle = annotationSubtitle
            mapView.addAnnotation(annotation)
            navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButton))
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { //Zoom in centerly to user current location
        
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation() //to prevent change the location we choose to save, over user current location

    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? { //Same pinView without navigation
        if annotation is MKUserLocation {
            return nil
        }
        let annotationID = "MyAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationID )
        
        if pinView == nil {
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationID)
            pinView?.canShowCallout = true //to show what user write for name and type of the location above the annotation
            pinView?.tintColor = .red
            
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func ErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true)
    }

    

    

}
