//
//  PostTableViewCell.swift
//  LocalReads
//
//  Created by Tom Seymour on 2/18/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit
import Cosmos

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var bookCoverImageView: UIImageView!
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    @IBOutlet weak var bookTitileLabel: UILabel!
  
    @IBOutlet weak var bookAuthorLabel: UILabel!
    
    @IBOutlet weak var libraryNameLabel: UILabel!
    
    @IBOutlet weak var userRatingLabel: UILabel!
    @IBOutlet weak var userCommentLabel: UILabel!
    
    
    
    @IBOutlet weak var bookCoverTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var coverLoadActivityIndicator: UIActivityIndicatorView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userProfileImageView.layer.cornerRadius = 22
        userProfileImageView.clipsToBounds = true
        
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.8
        cardView.layer.shadowOffset = CGSize(width: 0, height: 5)
        cardView.layer.shadowRadius = 8

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func rating(_ value: Int) {
        var ratingString = ""
        for _ in 1...value {
            ratingString += "⭐"
        }
        self.userRatingLabel.text = ratingString
    }
    
}
