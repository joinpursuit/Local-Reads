//
//  Post.swift
//  LocalReads
//
//  Created by Tom Seymour on 2/18/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import Foundation

class Post {
    let key: String
    let userID: String
    let userName: String
    let userRating: Int
    let userComment: String
    let bookTitle: String
    let bookAuthor: String
    let bookImageURL: String
    let libraryName: String
    
    init(key: String, userID: String, userName: String, userRating: Int, userComment: String, bookTitle: String, bookAuthor: String, bookImageURL: String, libraryName: String) {
        self.key = key
        self.userID = userID
        self.userName = userName
        self.userRating = userRating
        self.userComment = userComment
        self.bookTitle = bookTitle
        self.bookAuthor = bookAuthor
        self.bookImageURL = bookImageURL
        self.libraryName = libraryName
    }
    
    convenience init?(from dict: [String: AnyObject], key: String) {
        if let userName = dict["userName"] as? String,
            let userID = dict["userID"] as? String,
            let userRating = dict["userRating"] as? Int,
            let userComment = dict["userComment"] as? String,
            let bookTitle = dict["bookTitle"] as? String,
            let bookAuthor = dict["bookAuthor"] as? String,
            let bookImageURL = dict["bookImageURL"] as? String,
            let libraryName = dict["libraryName"] as? String {
            
            self.init(key: key, userID: userID, userName: userName, userRating: userRating, userComment: userComment, bookTitle: bookTitle, bookAuthor: bookAuthor, bookImageURL: bookImageURL, libraryName: libraryName)
        } else {
            return nil
        }
        
    }
    
}
