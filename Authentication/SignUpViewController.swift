//
//  SignUpViewController.swift
//  Authentication
//
//  Created by Amin Amjadi on 7/28/16.
//  Copyright © 2016 MDJD. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var vertifyPassTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func signUp() {
        if let email = emailTextField.text {
            if let pass = passwordTextField.text {
                if let verPass = vertifyPassTextField.text {
                    if pass == verPass {
                        FIRAuth.auth()?.createUserWithEmail(email, password: pass, completion: { (user , error) in
                            if error != nil {
                                let alertController = UIAlertController(title: "Alert", message: "Error", preferredStyle: .Alert)
                                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                                
                                self.presentViewController(alertController, animated: true, completion: nil)

                            }
                            else {
                                let alertController = UIAlertController(title: "Alert", message: "You have been signed up successfuly", preferredStyle: .Alert)
                                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                                
                                self.presentViewController(alertController, animated: true, completion: nil)

                            }
                        })
                    }
                    else {
                        let alertController = UIAlertController(title: "Warning", message: "Your passwords doesn't match", preferredStyle: .Alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)

                    }
                }
            }
        }
    }
    
}
