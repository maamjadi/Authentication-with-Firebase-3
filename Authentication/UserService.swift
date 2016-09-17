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

class UserService {
    
    static let userService = UserService()
    
    fileprivate let ref = FIRDatabase.database().reference()
    fileprivate let storage = FIRStorage.storage()
    // Create a storage reference from our storage service
    fileprivate let storageRef = userService.storage.reference(forURL: "gs://test-ae2fd.appspot.com")
    
    
    func signUp(_ name: String, email: String, pass: String, imageData: Data) -> Bool {
        var checkError: Bool = true
        FIRAuth.auth()?.createUser(withEmail: email, password: pass, completion: { (user , error) in
            if error != nil {
                print(error?.localizedDescription)
                checkError = false
                
            } else {
                if let user = FIRAuth.auth()?.currentUser {
                    
                    print("You have been signed up successfully")
                    
                    
                    let profilePicRef = self.storageRef.child("images"+"/Profile pictures"+"/\(user.uid).jpg")
                    
                    
                    self.ref.child("Users").child(user.uid).child("Licence/Type").setValue("free")
                    self.ref.child("Users").child(user.uid).child("Licence/Date of creation").setValue(FIRServerValue.timestamp())
                    
                    let changeRequest = user.profileChangeRequest()
                    
                    changeRequest.displayName = name
                    changeRequest.commitChanges { error in
                        if let error = error {
                            // An error happened.
                            checkError = false
                        } else {
                            // Profile updated.
                        }
                    }
                    
                    let uploadTask = profilePicRef.put(imageData, metadata:nil) { metadata,error in
                        if error == nil {
                            //size, content type or the download URL
                            let downloadURL: String = metadata!.downloadURLs![0].absoluteString
                            let changeRequest = user.profileChangeRequest()
                            
                            changeRequest.commitChanges { error in
                                if let error = error {
                                    // An error happened.
                                    print(error.localizedDescription)
                                    checkError = false
                                } else {
                                    // Profile updated.
                                }
                            }
                            
                        } else {
                            print("error in uploading the image")
                            checkError = false
                        }
                    }
                }
            }
        })
        return checkError
    }
}
