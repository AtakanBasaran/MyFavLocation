//
//  ViewController.swift
//  MyFavLocation
//
//  Created by Atakan Başaran on 25.09.2023.
//

import UIKit
import ParseCore

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var PlaceSeries = [Place]() //To store the location data from parse by using struct model
    var chosenPlaceName = ""
    var chosenType = ""
    var chosenComment = ""
    var chosenLongitude : Double?
    var chosenLatitude : Double?
    var chosenImage : PFFileObject?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButton))
        navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: .done, target: self, action: #selector(LogOut))
        
        getData()

    }
    
    @objc func addButton() {
        performSegue(withIdentifier: "toUploadVC", sender: nil)
    }
    
    @objc func LogOut() {
        PFUser.logOutInBackground { error in
            if error != nil {
                self.ErrorAlert(title: "Error!", message: error?.localizedDescription ?? "Error!")
            } else {
                self.performSegue(withIdentifier: "toSignVC", sender: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PlaceSeries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = PlaceSeries[indexPath.row].placeName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { 
        chosenType = PlaceSeries[indexPath.row].placeType
        chosenComment = PlaceSeries[indexPath.row].Comment
        chosenPlaceName = PlaceSeries[indexPath.row].placeName
        chosenLatitude = PlaceSeries[indexPath.row].latitude
        chosenLongitude = PlaceSeries[indexPath.row].longitude
        chosenImage = PlaceSeries[indexPath.row].placeImage
        performSegue(withIdentifier: "toMapVC", sender: nil)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //I have used prepare for segue method instead of global variables to transfer data
        
        if segue.identifier == "toMapVC" {
            let destinationVC = segue.destination as! MapViewController
            destinationVC.commentChosen = chosenComment
            destinationVC.nameChosen = chosenPlaceName
            destinationVC.typeChosen = chosenType
            destinationVC.latitudeChosen = chosenLatitude
            destinationVC.longitudeChosen = chosenLongitude
            destinationVC.imageChosen = chosenImage
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) { //User could delete the location for temporarily since I could not figure out how to delete objects in Parse with code
        if editingStyle == .delete {
            PlaceSeries.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        }
    }
    
    
    func ErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
    
    func getData() {
        
        let query = PFQuery(className: "Place")
        query.whereKey("userID", equalTo: PFUser.current()!) //Only take the data belong to the current user
        query.findObjectsInBackground { objects, error in
            if error != nil {
                self.ErrorAlert(title: "Error!", message: error?.localizedDescription ?? "Error!")
            } else {
                if objects != nil {
                    if objects!.count > 0 {
                        self.PlaceSeries.removeAll(keepingCapacity: false)
                        
                        for object in objects! {
                            if let placeName = object.object(forKey: "PlaceName") as? String {
                                if let placeType = object.object(forKey: "Type") as? String {
                                    if let comment = object.object(forKey: "Comment") as? String {
                                        if let placeImage = object.object(forKey: "PlaceImage") as? PFFileObject {
                                            if let latitude = object.object(forKey: "Latitude") as? Double {
                                                if let longitude = object.object(forKey: "Longitude") as? Double {
                                                    let place = Place(placeName: placeName, Comment: comment, placeType: placeType, placeImage: placeImage, latitude: latitude, longitude: longitude)
                                                    self.PlaceSeries.append(place)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        
    }
    
    


}
