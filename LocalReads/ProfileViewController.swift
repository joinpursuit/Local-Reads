//
//  ProfileViewController.swift
//  LocalReads
//
//  Created by Tong Lin on 2/18/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseDatabase
import FirebaseAuth

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var databaseReference: FIRDatabaseReference!
    
    var userPosts: [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lrPrimaryLight()
        self.databaseReference = FIRDatabase.database().reference().child("posts")
        setNavBar()
        setupViews()
        setConstraints()
        setProfilePic()
        fetchPosts()
    }
    
    func setProfilePic() {
        
    }
    
    func setNavBar() {
        let libraryButton = UIBarButtonItem(title: "Choose Library", style: .done, target: self, action: #selector(chooseLibraryTapped))
        
        let logoutButton = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logoutButtonTapped))
        
        self.navigationItem.rightBarButtonItem = libraryButton
        self.navigationItem.leftBarButtonItem = logoutButton
        
    }

    
    func setupViews() {
        self.tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCellIdentifyer")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableViewAutomaticDimension

        self.view.addSubview(profileImageView)
        self.view.addSubview(tableView)
    }
    
    func setConstraints() {
        self.edgesForExtendedLayout = []
        
        self.profileImageView.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(8)
            view.height.equalToSuperview().multipliedBy(0.3)
            view.width.equalTo(self.profileImageView.snp.height)
            view.centerX.equalToSuperview()
        }
        
        self.tableView.snp.makeConstraints { (view) in
            view.bottom.leading.trailing.equalToSuperview()
            view.top.equalTo(profileImageView.snp.bottom).offset(8)
        }
    }
    
    
    // MARK: - Posts
    
    func fetchPosts() {
        databaseReference.observeSingleEvent(of: .value, with: { (snapshot: FIRDataSnapshot) in
            var fetchedPosts: [Post] = []
            for child in snapshot.children {
                if let snap = child as? FIRDataSnapshot, let valueDict = snap.value as? [String: AnyObject] {
                    
                    if let post = Post(from: valueDict, key: snap.key) {
                        fetchedPosts.append(post)
                    }
                }
            }
            // chronological order
            self.userPosts = fetchedPosts.filter{ $0.userName == LoginViewController.currentUser.name }.reversed()
            self.tableView.reloadData()
        })
    }
    
    
    // MARK: - Tableview Data
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCellIdentifyer", for: indexPath) as! PostTableViewCell
        
        let post = userPosts[indexPath.row]
        
        cell.usernameLabel.text = post.userName
        cell.bookTitileLabel.text = post.bookTitle
        cell.bookAuthorLabel.text = post.bookAuthor
        cell.libraryNameLabel.text = post.libraryName
        cell.userRatingLabel.text = String(post.userRating)
        cell.userCommentLabel.text = post.userComment
        cell.bookCoverImageView.image = nil
        cell.coverLoadActivityIndicator.hidesWhenStopped = true
        cell.coverLoadActivityIndicator.startAnimating()
        APIRequestManager.manager.getData(endPoint: post.bookImageURL) { (data) in
            if let data = data {
                DispatchQueue.main.async {
                    cell.bookCoverImageView.image = UIImage(data: data)
                    cell.coverLoadActivityIndicator.stopAnimating()
                    cell.setNeedsLayout()
                }
            }
        }
        return cell

    }
    
    
    // MARK: - Actions
    
    func chooseLibraryTapped() {
        
        print("tap")
    }
    
    func logoutButtonTapped() {
        if FIRAuth.auth()?.currentUser != nil {
            do {
                try FIRAuth.auth()?.signOut()
                print("logged out")
                self.dismiss(animated: true, completion: nil)
            } catch {
                print("Error occured while logging out: \(error)")
            }
        }

    }

   
    // MARK: - Lazy vars
    
    lazy var profileImageView: UIImageView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "user_icon")
        view.backgroundColor = UIColor.lrPrimary()
        view.layer.cornerRadius = 90
        view.clipsToBounds = true
        return view
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        return view
    }()

}
