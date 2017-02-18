//
//  PostTableViewCell.swift
//  LocalReads
//
//  Created by Tom Seymour on 2/18/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var bookCoverImageView: UIImageView!
    @IBOutlet weak var bookTitileLabel: UILabel!
  
    @IBOutlet weak var bookAuthorLabel: UILabel!
    
    @IBOutlet weak var libraryNameLabel: UILabel!
    
    @IBOutlet weak var userRatingLabel: UILabel!
    @IBOutlet weak var userCommentLabel: UILabel!
    
    
    @IBOutlet weak var coverLoadActivityIndicator: UIActivityIndicatorView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
