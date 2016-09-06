//
//  ProfileTableViewController.swift
//
//
//  Created by Amin Amjadi on 8/8/16.
//
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class ProfileTableViewController: UITableViewController {
    
    
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verifyPassTextField: UITextField!
    
    let imagePicker = UIImagePickerController()
    var selectedPhoto = UIImage!(nil)
    var successfullyUpdated: Bool = false
    
    let ref = FIRDatabase.database().reference()
    let user = FIRAuth.auth()?.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
        self.profileImage.clipsToBounds = true
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileTableViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileTableViewController.selectPhoto(_:)))
        profileImage.addGestureRecognizer(tapRecognizer)
        
        // User is signed in.
        let name = user?.displayName
        let email = user?.email
        
        self.emailTextField.text = email
        self.nameTextField.text = name
        
        // Get a reference to the storage service, using the default Firebase App
        let storage = FIRStorage.storage()
        // Create a storage reference from our storage service
        let storageRef = storage.referenceForURL("gs://test-ae2fd.appspot.com")
        let profilePicRef = storageRef.child("Profile pic"+"/\(user?.uid).jpg")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        profilePicRef.dataWithMaxSize(2 * 1024 * 1024) { (data, error) -> Void in
            if (error != nil) {
                // Uh-oh, an error occurred!
                print("Unable to download image")
            } else {
                // Data for "images" is returned
                // ... let islandImage: UIImage! = UIImage(data: data!)
                
                if data != nil {
                    print("user already has an image, no need to download from facebook")
                    self.profileImage.image = UIImage(data: data!)
                }
            }
            
        }
        
        var refHandle = self.ref.child("Users").observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            if snapshot.hasChild((self.user?.uid)! + "/Personal information") {
            let usersDict = snapshot.value as! NSDictionary
            // ...
            let userPersonalInformation = usersDict.objectForKey(self.user!.uid)?.objectForKey("Personal information")
            self.birthdayTextField.text = userPersonalInformation?.objectForKey("Birthday") as? String
            }
        })
        
    }
    
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
    
    
    
    @IBAction func timeTextFieldEditingBegin(sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        //This will update textfields text with value of datepicker
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        birthdayTextField.text = dateFormatter.stringFromDate(sender.date)
        
    }
    
    @IBAction func updateProfile() {
        
        if successfullyUpdated == false {
            self.successfullyUpdated = true
            if let email = self.emailTextField.text where email != ""{
                self.user?.updateEmail(email) { error in
                    if let error = error {
                        // An error happened.
                        let alertControll = UIAlertController(title: "Alert", message: "Please enter valid email address!", preferredStyle: .Alert)
                        alertControll.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                        
                        self.presentViewController(alertControll, animated: true, completion: nil)
                        self.successfullyUpdated = false
                    } else {
                        // Email updated.
                    }
                }
            }
            
            if let newPassword = self.passwordTextField.text where newPassword != "" {
                if newPassword == verifyPassTextField.text {
                    self.user?.updatePassword(newPassword) { error in
                        if let error = error {
                            // An error happened.
                            
                            let alertControll = UIAlertController(title: "Alert", message: "Password must be at least 6 digits!", preferredStyle: .Alert)
                            alertControll.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                            
                            self.presentViewController(alertControll, animated: true, completion: nil)
                            self.successfullyUpdated = false
                        } else {
                            // Password updated.
                        }
                    }
                } else {
                    let alertController = UIAlertController(title: "Warning", message: "Your passwords doesn't match", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    self.successfullyUpdated = false
                }
            }
            
            if let user = user {
                let changeRequest = user.profileChangeRequest()
                
                if self.nameTextField.text != nil {
                    changeRequest.displayName = self.nameTextField.text
                }
                
                if profileImage.image != nil {
                    // Get a reference to the storage service, using the default Firebase App
                    let storage = FIRStorage.storage()
                    // Create a storage reference from our storage service
                    let storageRef = storage.referenceForURL("gs://test-ae2fd.appspot.com")
                    let profilePicRef = storageRef.child("Profile pic"+"/\(user.uid).jpg")
                    let data: NSData = UIImageJPEGRepresentation(self.profileImage.image!, 1)!
                    let uploadTask = profilePicRef.putData(data, metadata: nil) { metadata, error in
                        if (error != nil) {
                            // Uh-oh, an error occurred!
                            self.successfullyUpdated = false
                        } else {
                            // Metadata contains file metadata such as size, content-type, and download URL.
                            let downloadURL = metadata!.downloadURL
                        }
                    }
                }
            }
            
            if let birthday = birthdayTextField.text where birthday != "" {
                self.ref.child("Users").child(user!.uid).child("Personal information/Birthday").setValue(birthday)
            }
        } else {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let mainView = mainStoryboard.instantiateViewControllerWithIdentifier("mainView")
            
            self.presentViewController(mainView, animated: true, completion: nil)
        }
    }
    
    
    
}

extension ProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
