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
import FirebaseStorage


class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var allPosts: [Post] = [] {
        didSet {
            if let library = FeedViewController.libraryToFilterBy {
                self.filteredPosts = allPosts.filter { $0.libraryName == library.name }
                navigationItem.title = library.name
            } else {
                self.filteredPosts = allPosts
                navigationItem.title = "All Queens Libraries"
            }
        }
    }
    
    var filteredPosts: [Post] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    static var libraryToFilterBy: Library?
    
    var databaseReference: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.databaseReference = FIRDatabase.database().reference().child("posts")
        
        setNavBar()
        setupViews()
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPosts()
        if let library = FeedViewController.libraryToFilterBy {
            navigationItem.title = library.name
        } else {
            
        }
    }
    
    // MARK: - Setup
    
    func setNavBar() {
        self.navigationController?.navigationBar.tintColor = ColorManager.shared.accent
        let filterButton = UIBarButtonItem(image: #imageLiteral(resourceName: "filterIcon"), style: .done, target: self, action: #selector(libraryFilterTapped))
//        let filterButton = UIBarButtonItem(title: "Library Filter", style: .done, target: self, action: #selector(libraryFilterTapped))
        self.navigationItem.rightBarButtonItem = filterButton
    }
    
    func setupViews() {
        
        self.view.addSubview(tableView)
        self.tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCellIdentifyer")
        self.tableView.addSubview(self.refreshControl)
        self.tableView.backgroundColor = ColorManager.shared.primaryLight
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = .none
        self.view.addSubview(floatingButton)

    }
    
    
    func setConstraints() {
        self.edgesForExtendedLayout = []
        tableView.snp.makeConstraints { (view) in
            view.top.bottom.leading.trailing.equalToSuperview()
        }
        
        floatingButton.snp.makeConstraints { (view) in
            view.width.height.equalTo(54)
            view.trailing.bottom.equalToSuperview().offset(-20)
        }
    }
    
    
    // MARK: - Posts 
    
    func fetchPosts() {
        databaseReference.observe(.value, with: { (snapshot) in
            var fetchedPosts: [Post] = []
            for child in snapshot.children {
                if let snap = child as? FIRDataSnapshot, let valueDict = snap.value as? [String: AnyObject] {
                    
                    if let post = Post(from: valueDict, key: snap.key) {
                        fetchedPosts.append(post)
                    }
                }
            }
            self.allPosts = fetchedPosts.reversed()
        })
    }
    
    
    
    //MARK: - Tableview delegates/datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCellIdentifyer", for: indexPath) as! PostTableViewCell
        
        let post = filteredPosts[indexPath.row]
        
        cell.usernameLabel.text = post.userName
        cell.bookTitileLabel.text = post.bookTitle
        cell.bookAuthorLabel.text = "by: \(post.bookAuthor)"
        cell.libraryNameLabel.text = "Library:  \(post.libraryName)"
        cell.rating(post.userRating)
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
        cell.userProfileImageView.image = nil
        let storageReference: FIRStorageReference = FIRStorage.storage().reference(forURL: "gs://localreads-8eb86.appspot.com/")
        let spaceRef = storageReference.child("profileImages/\(post.userID)")
        
        spaceRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
            } else {
                let image = UIImage(data: data!)
                cell.userProfileImageView.image = image
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = filteredPosts[indexPath.row]
        let profileVC = ProfileViewController()
        profileVC.viewType = .vistor
        profileVC.profileUserID = post.userID
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
    
    // Actions
    
    func libraryFilterTapped() {
        let libraryVC = LibraryFilterViewController()
        libraryVC.viewStyle = .fromFeed
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        navigationController?.pushViewController(libraryVC, animated: true)
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        fetchPosts()
        refreshControl.endRefreshing()
    }
    
    func floatingButtonClicked(sender: UIButton) {
        let newTransform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        let originalTransform = sender.imageView!.transform
        
        UIView.animate(withDuration: 0.1, animations: {
            sender.layer.transform = CATransform3DMakeAffineTransform(newTransform)
        }, completion: { (complete) in
            sender.layer.transform = CATransform3DMakeAffineTransform(originalTransform)
        })
        
        present(AddPostViewController(), animated: true, completion: nil)
        
    }
    
    // Lazy vars
    
    
    internal lazy var floatingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(floatingButtonClicked(sender:)), for: UIControlEvents.touchUpInside)
        button.setImage(UIImage(named: "plus_symbol")!, for: .normal)
        button.backgroundColor = ColorManager.shared.accent
        button.layer.cornerRadius = 26
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.8
        button.layer.shadowOffset = CGSize(width: 0, height: 5)
        button.layer.shadowRadius = 5
        button.clipsToBounds = false
        return button
    }()

    
    lazy var tableView: UITableView = {
        let view = UITableView()
        return view
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    

    
}
