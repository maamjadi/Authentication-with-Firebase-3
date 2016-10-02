//
//  Error.swift
//  Authentication
//
//  Created by Amin Amjadi on 10/2/16.
//  Copyright © 2016 MDJD. All rights reserved.
//

import Foundation

class Error {
    
    private var knownError = [String:Err]()
    
    private enum Err {
        case User(Bool?)
    }
    
    init() {
        knownError["UserService"] = Err.User(true)
    }
    
    func giveError(typeOfError: String) -> Bool {
        if let errType = knownError[typeOfError] {
            switch errType {
            case .User(let error):
                if let err = error {
                    return err
                }
            }
        }
        return false
    }
    
    func changeError(typeOfError: String, error: Bool?) {
        if let errType = knownError[typeOfError] {
            switch errType {
            case .User(_):
                knownError[typeOfError] = Err.User(error)
            }
        }
    }
    
}
