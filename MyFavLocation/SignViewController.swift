//
//  SignViewController.swift
//  MyFavLocation
//
//  Created by Atakan Başaran on 25.09.2023.
//

import UIKit
import ParseCore

class SignViewController: UIViewController {
    
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    
    @IBAction func SignInButton(_ sender: Any) {
        
        if userNameTextField.text != "" && passwordTextField.text != "" {
            
            PFUser.logInWithUsername(inBackground: userNameTextField.text!, password: passwordTextField.text!) { user, error in
                if error != nil {
                    self.ErrorAlert(title: "Error!", message: error?.localizedDescription ?? "Error")
                } else {
                    self.performSegue(withIdentifier: "toVC", sender: nil)
                }
            }
        } else {
            ErrorAlert(title: "Error!", message: "Username and Password cannot be empty!")
        }
    }
    

    @IBAction func SignUpButton(_ sender: Any) {
        
        if userNameTextField.text != "" && passwordTextField.text != "" {
            
            let user = PFUser()
            user.username = userNameTextField.text
            user.password = passwordTextField.text
            user.signUpInBackground { succes, error in
                
                if error != nil {
                    self.ErrorAlert(title: "Error!", message: error?.localizedDescription ?? "Error!")
                } else {
                    self.performSegue(withIdentifier: "toVC", sender: nil)
                }
            }
   
        } else {
            ErrorAlert(title: "Error!", message: "Username and Password cannot be empty!")
        }
    }
    
    func ErrorAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
}
