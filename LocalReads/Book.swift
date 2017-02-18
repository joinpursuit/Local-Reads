//
//  Book.swift
//  LocalReads
//
//  Created by Tom Seymour on 2/18/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import Foundation

class Book {
    var title: String
    var author: String
    var publishedDate: String
    var thumbNail: String
    
    
    init(title: String, author: String, publishedDate: String, thumbNail: String) {
        
        self.title = title
        self.author = author
        self.publishedDate = publishedDate
        self.thumbNail = thumbNail
    }
    
    convenience init?(from dictionary: [String:Any])  {
        if let bookInfo = dictionary["volumeInfo"] as? [String: Any] {
            
            let title = bookInfo["title"] as! String
            let publishedDate = bookInfo["publishedDate"] as! String
            let authorsArray = bookInfo["authors"] as! [String]
            let author = authorsArray[0]
            let thumbNailDict = bookInfo["imageLinks"] as? [String: String] ?? ["thumbnail":""]
            let thumbNail = thumbNailDict["thumbnail"]!
            
            self.init(title: title, author: author, publishedDate: publishedDate, thumbNail: thumbNail)
        } else {
            return nil
        }
    }
    
  
    static func parseBooks(from: Data?) -> [Book]? {
        var allBooks: [Book] = []
        
        
        let data = try? JSONSerialization.jsonObject(with: from!, options: [])
        guard let validJson = data as? [String: Any] else { return nil }
        guard let items = validJson["items"] as? [[String: Any]] else { return nil }
        
        
        for books in items {
            allBooks.append(Book(from: books)!)
        }

        return allBooks
    }

}
//Call For Books
//URL https://www.googleapis.com/books/v1/volumes?q=\(user input)
//APIRequestManager.manager.getData(endPoint: url) { (data) in
//    if  let validData = data,
//        let validBooks = Book.parseBooks(from: validData) {
//        self.books = validBooks
//    }
//}
