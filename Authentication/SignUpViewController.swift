//
//  SignUpViewController.swift
//  Authentication
//
//  Created by Amin Amjadi on 7/28/16.
//  Copyright © 2016 MDJD. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var vertifyPassTextField: UITextField!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var signUpButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    var selectedPhoto: UIImage! = UIImage(named: "profile pic")!
    
    
    let ref = FIRDatabase.database().reference()
    
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
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
        self.profileImage.clipsToBounds = true
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileTableViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileTableViewController.selectPhoto(_:)))
        profileImage.addGestureRecognizer(tapRecognizer)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func selectPhoto(_ gestureRecognizer: UITapGestureRecognizer)
    {
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.imagePicker.sourceType = .camera
        } else {
            self.imagePicker.sourceType = .photoLibrary
        }
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func signUp() {
        guard let name = nameTextField.text , !name.isEmpty, let email = emailTextField.text , !email.isEmpty, let pass = passwordTextField.text , !pass.isEmpty, let verPass = vertifyPassTextField.text , !verPass.isEmpty else {
            
            let alertController = UIAlertController(title: "Warning", message: "Please fill all the informations", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        if let pass = passwordTextField.text {
            if let verPass = vertifyPassTextField.text {
                if pass == verPass {
                    self.hidden(true)
                    self.loadingSpinner.startAnimating()
                    var data = Data()
                    data = UIImageJPEGRepresentation(profileImage.image!, 0.1)!
                    if UserService.userService.signUp(nameTextField.text!, email: emailTextField.text!, pass: passwordTextField.text!, imageData: data) {
                        
                    } else {
                        self.hidden(false)
                        self.loadingSpinner.stopAnimating()
                    }
                    let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.login()
                } else {
                    let alertController = UIAlertController(title: "Warning", message: "Your passwords doesn't match", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }
            }
            
        }
    }
    
    func hidden(_ bool: Bool) {
        self.nameTextField.isHidden = bool
        self.vertifyPassTextField.isHidden = bool
        self.emailTextField.isHidden = bool
        self.passwordTextField.isHidden = bool
        self.profileImage.isHidden = bool
        self.signUpButton.isHidden = bool
    }
    
    
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //imagePicker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        selectedPhoto = info[UIImagePickerControllerEditedImage] as? UIImage
        self.profileImage.image = selectedPhoto
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

