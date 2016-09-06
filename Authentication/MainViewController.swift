//
//  MainViewController.swift
//  Authentication
//
//  Created by Amin Amjadi on 7/30/16.
//  Copyright © 2016 MDJD. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FirebaseAuth

class MainViewController: UIViewController {

    @IBOutlet weak var nameTextField: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var typeOfAccTextField: UILabel!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
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
        
        navigationController?.navigationBarHidden = true

        // Do any additional setup after loading the view.
    }

}
