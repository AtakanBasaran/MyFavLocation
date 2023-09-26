//
//  UploadViewController.swift
//  MyFavLocation
//
//  Created by Atakan Başaran on 25.09.2023.
//

import UIKit

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonNext: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonNext.isEnabled = false
        
        
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PickImage))
        imageView.addGestureRecognizer(gestureRecognizer)
        
        let gestureRecongnizerKeyboard = UITapGestureRecognizer(target: self, action: #selector(CloseKeyboard))
        view.addGestureRecognizer(gestureRecongnizerKeyboard)

    }
    
    @objc func CloseKeyboard() {
        view.endEditing(true)
    }
    
    @objc func PickImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        if nameTextField.text != "" && typeTextField.text != "" && commentTextField.text != "" {
            present(picker, animated: true)
        } else {
            ErrorAlert(title: "Error!", message: "Place name, type and comment cannot be blank!")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info [.editedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        buttonNext.isEnabled = true //to prevent saving nil data
    }
    
    
    @IBAction func nextButton(_ sender: Any) {
            performSegue(withIdentifier: "toUploadMapVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUploadMapVC" {
            let destinationVC = segue.destination as! UploadMapViewController
            destinationVC.annotationTitle = nameTextField.text!
            destinationVC.annotationSubtitle = typeTextField.text!
            destinationVC.chosenComment = commentTextField.text!
            destinationVC.chosenImage = imageView.image
        }
    }
    
    func ErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
    
    
    

}
