//
//  ViewController.swift
//  Authentication
//
//  Created by Amin Amjadi on 7/26/16.
//  Copyright © 2016 MDJD. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var fbLoginButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var startingViewSpinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hidden(false)
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in.
                let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let mainViewController: UIViewController = mainStoryBoard.instantiateViewController(withIdentifier: "mainView")
                
                self.present(mainViewController, animated: true, completion: nil)
            }
            else {
                // No user is signed in.
            }
        }
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    @IBAction func login() {
        if let email = emailTextField.text {
            if let pass = passwordTextField.text {
                
                FIRAuth.auth()?.signIn(withEmail: email, password: pass, completion: { (user, error) in
                    
                    if error != nil {
                        let alertController = UIAlertController(title: "Alert", message: "Error", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    else {
                        let alertController = UIAlertController(title: "Alert", message: "You have been loged in", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                })
                
            }
        }
    }
    
    @IBAction func facebookLoginButton() {
        
        self.hidden(true)
        self.startingViewSpinner.startAnimating()
        
        let login: FBSDKLoginManager = FBSDKLoginManager()
        login.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self, handler: { (result, error) -> Void in
            
            if error != nil {
                self.hidden(false)
                self.startingViewSpinner.stopAnimating()
                let alertController = UIAlertController(title: "Alert", message: "Error...", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            }
                
            else if (result?.isCancelled)! {
                self.hidden(false)
                self.startingViewSpinner.stopAnimating()
                let alertController = UIAlertController(title: "Alert", message: "Process Canceled...", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            }
                
            else {
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                    
                    print("You have been loged in")
                }
            }
            
        })
        
    }
    
    func hidden(_ bool: Bool) {
        self.fbLoginButton.isHidden = bool
        self.loginButton.isHidden = bool
        self.emailTextField.isHidden = bool
        self.passwordTextField.isHidden = bool
        self.signUpButton.isHidden = bool
    }
    
}


