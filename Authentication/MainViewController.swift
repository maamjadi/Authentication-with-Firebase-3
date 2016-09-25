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
        
        FBSDKAccessToken.setCurrent(nil)
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loggingView: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "loginView")
        
        self.present(loggingView, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        typeOfAccTextField.isHidden = true
        nameTextField.isHidden = true
        profileImage.layer.cornerRadius = profileImage.frame.size.height/2
        profileImage.clipsToBounds = true
        
        navigationController?.isNavigationBarHidden = true
        
        if let user = FIRAuth.auth()?.currentUser {
            // User is signed in.
            loadingSpinner.startAnimating()
            
            if let name = user.displayName {
                nameTextField.text = name
                nameTextField.isHidden = false  
            }
            let uid = user.uid
            
            var refHandle = self.ref.child("Users").observe(FIRDataEventType.value, with: { (snapshot) in
                if snapshot.hasChild((uid) + "/Licence") {
                    let usersDict = snapshot.value as! NSDictionary
                    // ...
                    let userPersonalInformation = (usersDict.object(forKey: uid) as AnyObject).object(forKey: "Licence")
                    self.typeOfAccTextField.text = (userPersonalInformation as? AnyObject)?.object(forKey: "Type") as? String
                    self.typeOfAccTextField.isHidden = false
                }
            })
            if let photoURL = user.photoURL {
            if let data = try? Data(contentsOf: photoURL) {
                self.profileImage.image = UIImage(data: data)
            }
            }
            
            let storage = FIRStorage.storage()
            // Create a storage reference from our storage service
            let storageRef = storage.reference(forURL: "gs://test-ae2fd.appspot.com")
            let profilePicRef = storageRef.child("images"+"/Profile pictures"+"/\(uid).jpg")
            
            profilePicRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) -> Void in
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
                let profilePic = FBSDKGraphRequest(graphPath: "me/picture", parameters: ["height": 300, "width": 300, "redirect": false], httpMethod: "GET")
                profilePic?.start(completionHandler: {(connection, result, error) -> Void in
                    // Handle the result
                    
                    if error == nil {
                        let dictionary = result as? NSDictionary
                        let data = dictionary?.object(forKey: "data")
                        
                        let urlPic = ((data as AnyObject).object(forKey: "url"))! as! String
                        if let imageData = try? Data(contentsOf: URL(string: urlPic)!) {
                            
                            let uploadTask = profilePicRef.put(imageData, metadata:nil) { metadata,error in
                                
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
                profileImage.isHidden = true
            }
            
        } else {
            // No user is signed in.
        }
        
    }
    
}
