//
//  MainViewController.swift
//  Authentication
//
//  Created by Amin Amjadi on 7/30/16.
//  Copyright © 2016 MDJD. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Firebase

class MainViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var typeOfAccTextField: UILabel!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    let ref = FIRDatabase.database().reference()
    
    var profilePicExistInStorage = false
    
    @IBAction func logOut() {
        
        //signs the user out of firebase app
        try! FIRAuth.auth()!.signOut()
        
        FBSDKAccessToken.setCurrentAccessToken(nil)
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loggingView: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("loginView")
        
        self.presentViewController(loggingView, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        typeOfAccTextField.hidden = true
        profileImage.layer.cornerRadius = profileImage.frame.size.height/2
        profileImage.clipsToBounds = true
        
        navigationController?.navigationBarHidden = true
        
        if let user = FIRAuth.auth()?.currentUser {
            // User is signed in.
            loadingSpinner.startAnimating()
            
            let name = user.displayName
            let uid = user.uid
            
            nameTextField.text = name
            var refHandle = self.ref.child("Users").observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
                if snapshot.hasChild((uid) + "/Licence") {
                    let usersDict = snapshot.value as! NSDictionary
                    // ...
                    let userPersonalInformation = usersDict.objectForKey(uid)?.objectForKey("Licence")
                    self.typeOfAccTextField.text = userPersonalInformation?.objectForKey("Type") as? String
                    self.typeOfAccTextField.hidden = false
                }
            })
            if let photoURL = user.photoURL {
            if let data = NSData(contentsOfURL: photoURL) {
                self.profileImage.image = UIImage(data: data)
            }
            }
            
            let storage = FIRStorage.storage()
            // Create a storage reference from our storage service
            let storageRef = storage.referenceForURL("gs://test-ae2fd.appspot.com")
            let profilePicRef = storageRef.child("images"+"/Profile pictures"+"/\(uid).jpg")
            
            profilePicRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                if (error != nil) {
                    // Uh-oh, an error occurred!
                    print("unable to download the image")
                    
                } else {
                    // Data for "images/island.jpg" is returned
                    // ... let islandImage: UIImage! = UIImage(data: data!)
                    if data != nil {
                        print("user already has an image, no need to download it from facebook")
                        self.profileImage.image = UIImage(data: data!)
                        self.loadingSpinner.stopAnimating()
                        self.profilePicExistInStorage = true
                    }
                    
                }
            }
            
            if profilePicExistInStorage != true {
                var profilePic = FBSDKGraphRequest(graphPath: "me/picture", parameters: ["height": 300, "width": 300, "redirect": false], HTTPMethod: "GET")
                profilePic.startWithCompletionHandler({(connection, result, error) -> Void in
                    // Handle the result
                    
                    if error == nil {
                        let dictionary = result as? NSDictionary
                        let data = dictionary?.objectForKey("data")
                        
                        let urlPic = (data?.objectForKey("url"))! as! String
                        if let imageData = NSData(contentsOfURL: NSURL(string: urlPic)!) {
                            
                            let uploadTask = profilePicRef.putData(imageData, metadata:nil) { metadata,error in
                                
                                if error == nil {
                                    //size, content type or the download URL
                                    let downloadURL = metadata!.downloadURL
                                    self.profilePicExistInStorage = true
                                } else {
                                    print("error in downloading image")
                                }
                            }
                            self.profileImage.image = UIImage(data: imageData)
                        }
                    }
                    
                })
            }
            loadingSpinner.stopAnimating()
            if profileImage.image == nil {
                profileImage.hidden = true
            }
            
        } else {
            // No user is signed in.
        }
        
    }
    
}
