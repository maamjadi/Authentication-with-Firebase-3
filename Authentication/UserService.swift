//
//  UserService.swift
//  Authentication
//
//  Created by Amin Amjadi on 9/7/16.
//  Copyright © 2016 MDJD. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FBSDKLoginKit

class UserService {
    
    static let userService = UserService()
    
    fileprivate let ref = FIRDatabase.database().reference()
    fileprivate let storageRef = FIRStorage.storage().reference()
    // Create a storage reference from our storage service
    
    
    func signUp(_ name: String, email: String, pass: String, imageData: Data) {
        UserService.error.checkError = nil
        FIRAuth.auth()?.createUser(withEmail: email, password: pass, completion: { (user , error) in
            UserService.error.checkError = true
            if error != nil {
                print(error?.localizedDescription)
                UserService.error.checkError = false
                return
                
            } else {
                if let user = FIRAuth.auth()?.currentUser {
                    
                    let profilePicRef = self.storageRef.child("images"+"/Profile pictures"+"/\(user.uid).jpg")
                    
                    self.ref.child("Users").child(user.uid).child("Licence/Type").setValue("free")
                    self.ref.child("Users").child(user.uid).child("Licence/Date of creation").setValue(FIRServerValue.timestamp())
                    
                    let changeRequest = user.profileChangeRequest()
                    
                    changeRequest.displayName = name
                    changeRequest.commitChanges { error in
                        if let error = error {
                            // An error happened.
                            UserService.error.checkError = false
                            return
                        } else {
                            // Profile updated.
                        }
                    }
                    
                    let uploadTask = profilePicRef.put(imageData, metadata:nil) { metadata,error in
                        if error == nil {
                            //size, content type or the download URL
                            let downloadURL: String = metadata!.downloadURLs![0].absoluteString
                            let changeRequest = user.profileChangeRequest()
                            changeRequest.photoURL = NSURL(fileURLWithPath: downloadURL) as URL
                            changeRequest.commitChanges { error in
                                if let error = error {
                                    // An error happened.
                                    print(error.localizedDescription)
                                    UserService.error.checkError = false
                                    return
                                } else {
                                    // Profile updated.
                                }
                            }
                        } else {
                            print("error in uploading the image")
                            UserService.error.checkError = false
                            return
                        }
                    }
                    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.login()
                }
            }
        })
    }
    private struct error {
        static var checkError: Bool? {
            get {
                return self.checkError
            }
            set {
                if let value = newValue {
                self.checkError = value
                }
            }
        }
    }
    
    class func giveError() -> Bool? {
        return UserService.error.checkError
    }
    
    func signIn(_ method: String, email: String?, pass: String?) {
        UserService.error.checkError = nil
        switch method {
            
        case "Email":
            FIRAuth.auth()?.signIn(withEmail: email!, password: pass!, completion: { (user, error) in
                UserService.error.checkError = true
                if error != nil {
                    //                let alertController = UIAlertController(title: "Alert", message: "Error", preferredStyle: .alert)
                    //                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    //
                    //                self.present(alertController, animated: true, completion: nil)
                    UserService.error.checkError = false
                    return
                } else {
                    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.login()
                }
                
            })
            
        case "Facebook":
            let login: FBSDKLoginManager = FBSDKLoginManager()
            login.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], handler: { (result, error) -> Void in
                
                if error != nil {
                    UserService.error.checkError = false
                    return
                }
                    
                else if (result?.isCancelled)! {
                    UserService.error.checkError = false
                    return
                }
                    
                else {
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                        if error == nil {
                            print("You have been loged in")
                            var refHandle = self.ref.child("Users").observe(FIRDataEventType.value, with: { (snapshot) in
                                if !(snapshot.hasChild((user?.uid)! + "/Licence")) {
                                    self.ref.child("Users").child((user?.uid)!).child("Licence/Type").setValue("free")
                                    self.ref.child("Users").child((user?.uid)!).child("Licence/Date of creation").setValue(FIRServerValue.timestamp())
                                }
                            })
                            
                        } else {
                            UserService.error.checkError = false
                            return
                        }
                    }
                }
                
            })
        //        case "Google":
        default: break
        }
        
    }
}
