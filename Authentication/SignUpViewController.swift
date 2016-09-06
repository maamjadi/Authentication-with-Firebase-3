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
    
    let imagePicker = UIImagePickerController()
    var selectedPhoto = UIImage!(nil)
    
    let ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hidden(false)
        
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in.
                let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let mainViewController: UIViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("mainView")
                
                self.presentViewController(mainViewController, animated: true, completion: nil)
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
    
    func selectPhoto(gestureRecognizer: UITapGestureRecognizer)
    {
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            self.imagePicker.sourceType = .Camera
        } else {
            self.imagePicker.sourceType = .PhotoLibrary
        }
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func signUp() {
        if let name = nameTextField.text where nameTextField.text != ""{
            if let email = emailTextField.text {
                if let pass = passwordTextField.text {
                    if let verPass = vertifyPassTextField.text {
                        if pass == verPass {
                            self.hidden(true)
                            self.loadingSpinner.startAnimating()
                            
                            FIRAuth.auth()?.createUserWithEmail(email, password: pass, completion: { (user , error) in
                                if error != nil {
                                    self.hidden(false)
                                    self.loadingSpinner.stopAnimating()
                                    let alertController = UIAlertController(title: "Alert", message: "Error", preferredStyle: .Alert)
                                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                                    
                                    self.presentViewController(alertController, animated: true, completion: nil)
                                    
                                }
                                else {
                                    if let user = FIRAuth.auth()?.currentUser {
                                        
                                        print("You have been signed up successfuly")
                                        
                                        let storage = FIRStorage.storage()
                                        // Create a storage reference from our storage service
                                        let storageRef = storage.referenceForURL("gs://test-ae2fd.appspot.com")
                                        let profilePicRef = storageRef.child("images"+"/Profile pictures"+"/\(user.uid).jpg")

                                        
                                        self.ref.child("Users").child(user.uid).child("Licence/Type").setValue("free")
                                        self.ref.child("User").child(user.uid).child("Licence/Date of creation").setValue(FIRServerValue.timestamp())
                                        
                                        let changeRequest = user.profileChangeRequest()
                                        
                                        changeRequest.displayName = self.nameTextField.text
                                        changeRequest.commitChangesWithCompletion { error in
                                            if let error = error {
                                                // An error happened.
                                            } else {
                                                // Profile updated.
                                            }
                                        }
                                        
//                                        if let imageData = NSData
//                                            
//                                            let uploadTask = profilePicRef.putData(imageData, metadata:nil) { metadata,error in
//                                                
//                                                if error == nil {
//                                                    //size, content type or the download URL
//                                                    let downloadURL = metadata!.downloadURL
//                                                    self.profilePicExistInStorage = true
//                                                } else {
//                                                    print("error in downloading image")
//                                                }
//                                            }
//                                            self.profileImage.image = UIImage(data: imageData)
//                                        }
//                                    }

                                        
                                    }
                                    
                                }
                            })
                        } else {
                            let alertController = UIAlertController(title: "Warning", message: "Your passwords doesn't match", preferredStyle: .Alert)
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                            
                            self.presentViewController(alertController, animated: true, completion: nil)
                            
                        }
                    }
                }
            }
        } else {
        let alertController = UIAlertController(title: "Warning", message: "Please fill all the informations", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func hidden(bool: Bool) {
        self.nameTextField.hidden = bool
        self.vertifyPassTextField.hidden = bool
        self.emailTextField.hidden = bool
        self.passwordTextField.hidden = bool
        self.profileImage.hidden = bool
    }
    
    
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //imagePicker Delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        selectedPhoto = info[UIImagePickerControllerEditedImage] as? UIImage
        self.profileImage.image = selectedPhoto
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

