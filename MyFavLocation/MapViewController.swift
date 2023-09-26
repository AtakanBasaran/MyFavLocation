//
//  MapViewController.swift
//  MyFavLocation
//
//  Created by Atakan Başaran on 25.09.2023.
//

import UIKit
import MapKit
import CoreLocation
import ParseCore

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeNameText: UILabel!
    @IBOutlet weak var typeLabel: UILabel!    
    @IBOutlet weak var commentLabel: UILabel!
    
    var nameChosen = ""
    var commentChosen = ""
    var typeChosen = ""
    var imageChosen : PFFileObject?
    var longitudeChosen : Double?
    var latitudeChosen : Double?
    

    override func viewDidLoad() {
        super.viewDidLoad()        
        
        mapView.delegate = self
    
        placeNameText.text = "Name: \(nameChosen)"
        typeLabel.text = "Type: \(typeChosen)"
        commentLabel.text = "Comment: \(commentChosen)"
        
        imageChosen?.getDataInBackground(block: { data, error in //tranform image to UIImage from data
            if error != nil {
                self.ErrorAlert(title: "Error!", message: error?.localizedDescription ?? "Error!")
            } else {
                if let data = data {
                    self.placeImage.image = UIImage(data: data)
                }
            }
        })
        
        let annotation = MKPointAnnotation() //annotation for the location of the selected table row
        annotation.title = nameChosen
        annotation.subtitle = typeChosen
        let coordinate = CLLocationCoordinate2D(latitude: latitudeChosen!, longitude: longitudeChosen!)
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? { //Change annotation style to add detail buttons for navigation
        
        if annotation is MKUserLocation { //Not create annotation for my location
            return nil
        }
        
        let annotationID = "MyAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationID )
        
        if pinView == nil { //Create pinView if does not exist
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationID)
            pinView?.canShowCallout = true
            pinView?.tintColor = .red
            
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
            
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) { //Adding deafult drive mode for navigation
        
        let requestLocation = CLLocation(latitude: latitudeChosen!, longitude: longitudeChosen!)
        CLGeocoder().reverseGeocodeLocation(requestLocation) { PlacemarkSeries, error in
            
            if let placemarkSeries = PlacemarkSeries {
                if placemarkSeries.count > 0 {
                    let NewPlacemark = MKPlacemark(placemark: placemarkSeries[0])
                    let item = MKMapItem(placemark: NewPlacemark)
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                    item.openInMaps(launchOptions: launchOptions)
                }
            }
        
        }
    }
    
    
    func ErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
    
}
