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
    let username: String
    let userRating: Int
    let userComment: String
    let bookTitle: String
    let bookImageURL: String
    let libraryName: String
    
    init(key: String, username: String, userRating: Int, userComment: String, bookTitle: String, bookImageURL: String, libraryName: String) {
        self.key = key
        self.username = username
        self.userRating = userRating
        self.userComment = userComment
        self.bookTitle = bookTitle
        self.bookImageURL = bookImageURL
        self.libraryName = libraryName
    }
    
    
}
