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
import FirebaseStorage

enum ProfileViewType {
    case admin
    case vistor
}

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var databaseReference: FIRDatabaseReference!
    
    var userPosts: [Post] = []
    
    static var chosenLibrary: Library?
    
    var viewType: ProfileViewType = .admin
    var profileUserID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ColorManager.shared.primaryDark
        self.databaseReference = FIRDatabase.database().reference().child("posts")
        
        if profileUserID == nil {
            profileUserID = (FIRAuth.auth()?.currentUser?.uid)!
        }
        
        setNavBar()
        setupViews()
        setConstraints()
        getUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPosts()
        
        if let library = ProfileViewController.chosenLibrary {
            self.userLibraryLabel.text = "Library: \(library.name)"
            // save libraray to use
            User.updateUserLibrary(library: library, completion: { 
                print("SUCCESS, updated userLibrary")
            })
        }
    }
    
    
    func setNavBar() {
        self.navigationController?.navigationBar.tintColor = ColorManager.shared.accent
        if viewType == .admin {
            let logoutButton = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logoutButtonTapped))
            self.navigationItem.rightBarButtonItem = logoutButton
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))

        } else {
            let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem = backButton
        }
    }

    
    func setupViews() {
        self.tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCellIdentifyer")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.backgroundColor = ColorManager.shared.primaryLight
        self.tableView.separatorStyle = .none

        self.view.addSubview(tableView)
        self.view.addSubview(noPostsLabel)
        self.view.addSubview(bannerView)
        bannerView.addSubview(profileImageView)
        bannerView.addSubview(userNameLabel)
        bannerView.addSubview(userLibraryLabel)
        bannerView.addSubview(userNumberOfPostsLabel)
        bannerView.addSubview(changeLibraryLabel)

        
        if self.viewType == .vistor {
            self.profileImageView.isUserInteractionEnabled = false
            self.changeLibraryLabel.isHidden = true
        }
        
        if self.userPosts.isEmpty {
            self.noPostsLabel.isHidden = false
        }
    }
    
    func setConstraints() {
        self.edgesForExtendedLayout = []
        
        self.bannerView.snp.makeConstraints { (view) in
            view.leading.trailing.top.equalToSuperview()
            view.height.equalToSuperview().multipliedBy(0.28)
        }
        
        self.profileImageView.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(8)
            view.bottom.equalToSuperview().offset(-8)
            view.width.equalTo(self.profileImageView.snp.height)
            view.leading.equalToSuperview().offset(40)
        }
        
        self.userNameLabel.snp.makeConstraints { (view) in
            view.bottom.equalTo(self.profileImageView.snp.centerY).offset(-20)
            view.leading.equalTo(self.profileImageView.snp.trailing).offset(8)
            view.trailing.equalToSuperview().offset(-8)
        }
        
        self.userNumberOfPostsLabel.snp.makeConstraints { (view) in
            view.top.equalTo(userNameLabel.snp.bottom).offset(8)
            view.leading.equalTo(self.profileImageView.snp.trailing).offset(8)
            view.trailing.equalToSuperview().offset(-8)
        }
        
        self.userLibraryLabel.snp.makeConstraints { (view) in
            view.top.equalTo(userNumberOfPostsLabel.snp.bottom).offset(8)
            view.leading.equalTo(self.profileImageView.snp.trailing).offset(8)
            view.trailing.equalToSuperview().offset(-8)
        }
        
        self.changeLibraryLabel.snp.makeConstraints { (view) in
            view.trailing.equalTo(self.userLibraryLabel.snp.trailing)
            view.top.equalTo(self.userLibraryLabel.snp.bottom).offset(4)
        }

        
        self.tableView.snp.makeConstraints { (view) in
            view.bottom.leading.trailing.equalToSuperview()
            view.top.equalTo(bannerView.snp.bottom)
        }
        
        self.noPostsLabel.snp.makeConstraints { (view) in
            view.leading.trailing.bottom.equalToSuperview()
            view.top.equalTo(self.bannerView.snp.bottom)
        }
    }
    
    
    
    func getUser() {
        let userReference = FIRDatabase.database().reference().child("users/\(profileUserID!)")
        userReference.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userDict = snapshot.value as? [String: Any],
                let userName = userDict["name"] as? String,
                let library = userDict["currentLibrary"] as? String {
                
                self.navigationItem.title = userName
                self.userNameLabel.text = userName
                
                if !library.isEmpty {
                    self.userLibraryLabel.text = "Library: \(library)"
                } else {
                    self.userLibraryLabel.text = "Please choose your library"
                }
                self.getUserImage()
            }
        })
    }
    
    func getUserImage() {
        let storageReference: FIRStorageReference = FIRStorage.storage().reference(forURL: "gs://localreads-8eb86.appspot.com/")
        let spaceRef = storageReference.child("profileImages/\(profileUserID!)")
        
        
        spaceRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
            } else {
                let image = UIImage(data: data!)
                self.profileImageView.image = image
            }
            UIView.animate(withDuration: 0.2, animations: {
                self.profileImageView.alpha = 1
                self.bannerView.setNeedsLayout()
            })
        }
    }
    
    func saveUserImage(imageData: Data) {
        let storageReference: FIRStorageReference = FIRStorage.storage().reference(forURL: "gs://localreads-8eb86.appspot.com/")
        let spaceRef = storageReference.child("profileImages/\(FIRAuth.auth()!.currentUser!.uid)")
        let metadata = FIRStorageMetadata()
        metadata.cacheControl = "public,max-age=300"
        metadata.contentType = "image/jpeg"
        
        _ = spaceRef.put(imageData, metadata: metadata, completion: { (metadata, error) in
            if error != nil {
                print("Error putting image to storage")
            }
        })

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
            self.userPosts = fetchedPosts.filter{ $0.userID == self.profileUserID }.reversed()
            self.tableView.reloadData()
            self.userNumberOfPostsLabel.text = "Posts: \(self.userPosts.count)"
            if !self.userPosts.isEmpty {
                self.noPostsLabel.isHidden = true
            }
        })
    }

    
    
    // MARK: - Tableview Data
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCellIdentifyer", for: indexPath) as! PostTableViewCell
        
        let post = userPosts[indexPath.row]
        
        cell.selectedBackgroundView?.backgroundColor = ColorManager.shared.primaryDark
        
        cell.usernameLabel.isHidden = true
        cell.userProfileImageView.isHidden = true
        cell.bookCoverTopConstraint.constant = 8
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch self.viewType {
        case .admin:
            return true
        case .vistor:
            return false
    
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = ColorManager.shared.primaryDark
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) && self.viewType == .admin {
            let postID = userPosts[indexPath.row].key
            databaseReference.child(postID).removeValue()
            
            userPosts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .right)
            self.userNumberOfPostsLabel.text = "Posts: \(self.userPosts.count)"
            if userPosts.isEmpty {
                self.noPostsLabel.alpha = 0
                self.noPostsLabel.isHidden = false
                UIView.animate(withDuration: 0.2, delay: 0.2, options: [], animations: { 
                    self.noPostsLabel.alpha = 1.0
                    self.view.setNeedsLayout()
                }, completion: nil)
            }
        }
    }
    
    //MARK: - ImagePickerController Delegate Method
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileImageView.image = image
            if let imageData = UIImageJPEGRepresentation(image, 0.5) {
                self.saveUserImage(imageData: imageData)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }

    
    
    // MARK: - Actions
    
    func profileImageTapped() {
        print("profile tap")
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.navigationBar.tintColor = ColorManager.shared.accent
        imagePickerController.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.white
        ]
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func chooseLibraryTapped() {
        let libraryVC = LibraryFilterViewController()
        libraryVC.viewStyle = .fromProfile
        navigationController?.pushViewController(libraryVC, animated: true)
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
    
    func editButtonPressed() {
        tableView.setEditing(true, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
    }
    
    func doneButtonPressed() {
        tableView.setEditing(false, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
    }

    

   
    // MARK: - Lazy vars
    
    lazy var profileImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = ColorManager.shared.primaryLight
        view.clipsToBounds = true
        view.alpha = 0
        view.image = #imageLiteral(resourceName: "user_icon")
        view.layer.cornerRadius = 70
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(profileImageTapped))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGestureRecognizer)
        return view
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        return view
    }()
    
    lazy var bannerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorManager.shared.primary
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.8
        view.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.layer.shadowRadius = 8

        return view
    }()
    
    lazy var userNameLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 18, weight: 14)
        view.textColor = .white
        return view
    }()
    
    lazy var userLibraryLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 14)
        view.textColor = .white
        return view
    }()
    
    lazy var userNumberOfPostsLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 16)
        view.textColor = .white
        return view
    }()
    
    lazy var changeLibraryLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 12)
        view.textColor = ColorManager.shared.accent
        view.text = "Change Library?"
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(chooseLibraryTapped))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGestureRecognizer)
        return view
    }()

    lazy var noPostsLabel: UILabel = {
        let view = UILabel()
        view.text = "No posts to display\nAdd a post from the main feed"
        view.numberOfLines = 2
        view.backgroundColor = ColorManager.shared.primary
        view.textColor = .white
        view.textAlignment = .center
        view.isHidden = true
        return view
    }()
    
    

}
