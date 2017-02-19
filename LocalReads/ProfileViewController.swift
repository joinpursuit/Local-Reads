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

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var databaseReference: FIRDatabaseReference!
    
    var userPosts: [Post] = []
    
    static var chosenLibrary: Library?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ColorManager.shared.primary
        self.databaseReference = FIRDatabase.database().reference().child("posts")
        setNavBar()
        setupViews()
        setConstraints()
        getUser()
        fetchPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let library = ProfileViewController.chosenLibrary {
            // save libraray to use
            User.updateUserLibrary(library: library, completion: { 
                print("SUCCESS, updated userLibrary")
            })
        }
    }
    
    
    func setNavBar() {
        self.navigationController?.navigationBar.tintColor = ColorManager.shared.accent

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
        self.tableView.backgroundColor = ColorManager.shared.primaryLight
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
    
    
    func getUser() {
        let userReference = FIRDatabase.database().reference().child("users/\(FIRAuth.auth()!.currentUser!.uid)")
        userReference.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userDict = snapshot.value as? [String: Any],
                let userName = userDict["name"] as? String {
                self.navigationItem.title = userName
            }
        })
        
        //get image
        let storageReference: FIRStorageReference = FIRStorage.storage().reference(forURL: "gs://localreads-8eb86.appspot.com/")
        let spaceRef = storageReference.child("profileImages/\(FIRAuth.auth()!.currentUser!.uid)")
        
        spaceRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
            } else {
                let image = UIImage(data: data!)
                self.profileImageView.image = image
            }
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
        
        cell.usernameLabel.isHidden = true
        cell.userProfileImageView.isHidden = true
        cell.bookCoverTopConstraint.constant = 8
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
    

   
    // MARK: - Lazy vars
    
    lazy var profileImageView: UIImageView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "user_icon")
        view.backgroundColor = UIColor.lrPrimary()
        view.clipsToBounds = true
        view.layer.cornerRadius = 88
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(profileImageTapped))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGestureRecognizer)
        return view
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        return view
    }()

}
