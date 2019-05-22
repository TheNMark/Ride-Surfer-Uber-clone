//
//  ViewController.swift
//  Ride Surfer
//
//  Created by Mark on 10/03/2019.
//  Copyright © 2019 Mark-Attila Nagy. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet var driverLabel: UILabel!
    @IBOutlet var riderLabel: UILabel!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var riderDriverSwitch: UISwitch!
    @IBOutlet var logInButton: UIButton!
    @IBOutlet var signUpButton: UIButton!
    
    var signUpMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        riderLabel.isHidden = true
        driverLabel.isHidden = true
        riderDriverSwitch.isHidden = true
        
    }

    @IBAction func logIn(_ sender: Any) {
        
        if emailTextField.text == "" || passwordTextField.text == "" {
            
            displayAlert(title: "Missing information", message: "You must provide both an email and password")
            
        } else {
            
            if let email = emailTextField.text {
                
                if let password = passwordTextField.text {
                    
                    if signUpMode {
                        // SIGN UP
                        
                        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                            if error != nil {
                                
                                self.displayAlert(title: "Oups", message: error!.localizedDescription)
                                
                            } else {
                                
                                if self.riderDriverSwitch.isOn {
                                    //DRIVER
                                    let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                    req?.displayName = "Driver"
                                    req?.commitChanges(completion: nil)
                                    
                                    self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                    
                                } else {
                                    //RIDER
                                    let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                    req?.displayName = "Rider"
                                    req?.commitChanges(completion: nil)
                                    
                                    self.performSegue(withIdentifier: "riderSegue", sender: nil)
                                    
                                }
                            }
                        }
                        
                    } else {
                        // LOG IN
                        
                        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                            if error != nil {
                                
                                self.displayAlert(title: "Oups", message: error!.localizedDescription)
                                
                            } else {
                                
                                if user?.user.displayName == "Driver" {
                                    //DRIVER
                                    self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                    
                                } else {
                                    //RIDER
                                    self.performSegue(withIdentifier: "riderSegue", sender: nil)
                                    
                                }
                            }
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func displayAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func signUp(_ sender: Any) {
        
        if signUpMode {
            
            logInButton.setTitle("Log in", for: .normal)
            signUpButton.setTitle("Sign up", for: .normal)
            riderLabel.isHidden = true
            driverLabel.isHidden = true
            riderDriverSwitch.isHidden = true
            signUpMode = false
            
        } else {
            
            logInButton.setTitle("Sign up", for: .normal)
            signUpButton.setTitle("Log in", for: .normal)
            riderLabel.isHidden = false
            driverLabel.isHidden = false
            riderDriverSwitch.isHidden = false
            signUpMode = true
            
        }
        
    }
    
}

