//
//  User.swift
//  LocalReads
//
//  Created by Tom Seymour on 2/18/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import Foundation
import Firebase

class User {
    let email: String
    let name: String
    var profileImage: String
    let currentLibrary: String
    
    init(email: String, name: String, profileImage: String, currentLibrary: String ) {
        self.email = email
        self.name = name
        self.profileImage = profileImage
        self.currentLibrary = currentLibrary
    }
    
    static func createUserInDatabase(email: String, name: String, profileImage: String, currentLibrary: String, completion: @escaping (() -> Void)) {
        
        let newUser = User(email: email, name: name, profileImage: profileImage, currentLibrary: currentLibrary )
        
        let databaseUserReference = FIRDatabase.database().reference().child("users")
        
        let newUserRef = databaseUserReference.child("\(FIRAuth.auth()!.currentUser!.uid)")
        
        let newUserDetails: [String : AnyObject] = [
            "email" : newUser.email as AnyObject,
            "name" : newUser.name as AnyObject,
            "profileImage" : newUser.profileImage as AnyObject,
            "currentLibrary" : newUser.currentLibrary as AnyObject
        ]
        
        newUserRef.setValue(newUserDetails) { (error, reference) in
            if error != nil {
                print("Error creating new user: \(error)")
            }
            completion()
        }
    }
    
    
    
}
