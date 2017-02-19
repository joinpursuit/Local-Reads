//
//  FeedViewController.swift
//  LocalReads
//
//  Created by Tong Lin on 2/18/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseDatabase


class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var posts: [Post] = []
    
    static var libraryToFilterBy: Library?
    
    var databaseReference: FIRDatabaseReference!
    
    var resultsTitle = "All Queens Libraries"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.databaseReference = FIRDatabase.database().reference().child("posts")
        
        setNavBar()
        setupViews()
        setConstraints()
        fetchPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("....library....")
        dump(FeedViewController.libraryToFilterBy)
        
        if let library = FeedViewController.libraryToFilterBy {
            self.posts = self.posts.filter { $0.libraryName == library.name }
            tableView.reloadData()
        }
    }
    
    // MARK: - Setup
    
    func setNavBar() {
        let filterButton = UIBarButtonItem(title: "Library Filter", style: .done, target: self, action: #selector(libraryFilterTapped))
        self.navigationItem.rightBarButtonItem = filterButton
    }
    
    func setupViews() {
        self.view.addSubview(tableView)
        self.tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCellIdentifyer")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableViewAutomaticDimension

    }
    
    
    func setConstraints() {
        self.edgesForExtendedLayout = []
        tableView.snp.makeConstraints { (view) in
            view.top.bottom.leading.trailing.equalToSuperview()
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
            self.posts = fetchedPosts.reversed()
            self.tableView.reloadData()
        })
    }
    
    
    
    //MARK: - Tableview delegates/datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCellIdentifyer", for: indexPath) as! PostTableViewCell
        
        let post = posts[indexPath.row]
        
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
    
    
    // Actions
    
    func libraryFilterTapped() {
        let libraryVC = LibraryFilterViewController()
        navigationController?.pushViewController(libraryVC, animated: true)
    }
    
    
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        return view
    }()
    
    

    
}
