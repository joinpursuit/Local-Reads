//
//  AddPostViewController.swift
//  LocalReads
//
//  Created by Tong Lin on 2/18/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit
import Firebase

class AddPostViewController: UIViewController, UISearchBarDelegate,  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var booksArray: [Book] = []
    var booksCollectionView: UICollectionView!
    var reuseIdentifier = "bookCell"
    var bookNibName = "BookCollectionViewCell"
    var apiEndpoint = "https://www.googleapis.com/books/v1/volumes?q="
    var selectedBook: Book!
    
    //Will Attempt To Get Stars System
    var ratingTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "What Book Have You Read"
        setupViewHierarchy()
        configureConstraints()
    }

    func setupViewHierarchy(){
        self.view.backgroundColor = .white
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        createBooksCollectionView()
        self.view.addSubview(searchBar)
        self.view.addSubview(booksCollectionView)
        self.view.addSubview(commentSection)
        self.view.addSubview(ratingSegment)
        
        let button = UIButton()
        button.setBackgroundImage(#imageLiteral(resourceName: "Button-Up-512"), for: .normal)
        button.snp.makeConstraints { (view) in
                        view.width.height.equalTo(35.0)
                  }
        button.addTarget(self, action: #selector(didTapUpload), for: .touchUpInside)
        let navButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = navButton
    }
    
    func configureConstraints(){
        searchBar.snp.makeConstraints { (view) in
            view.top.equalTo(self.topLayoutGuide.snp.bottom)
            view.leading.trailing.equalToSuperview()
        }
        booksCollectionView.snp.makeConstraints { (view) in
            view.top.equalTo(searchBar.snp.bottom).offset(10.0)
            view.leading.trailing.equalToSuperview()
            view.height.equalTo(250.0)
        }
        commentSection.snp.makeConstraints { (view) in
            view.bottom.equalToSuperview().inset(8.0)
            view.leading.equalToSuperview().offset(8.0)
            view.trailing.equalToSuperview().inset(8.0)
            view.height.equalTo(150.0)
        }
        ratingSegment.snp.makeConstraints { (view) in
            view.bottom.equalTo(commentSection.snp.top).offset(-8.0)
            view.leading.equalToSuperview().offset(8.0)
            view.width.equalTo(150.0)
        }
    }
    
    func didTapUpload() {
        
        guard selectedBook != nil else { return print("Pick a book bruh") }
        
        let databaseRef = FIRDatabase.database().reference()
        print(123)
        let key = databaseRef.childByAutoId()
        
        if let currentUser = LoginViewController.currentUser {
            let values = ["bookTitle" : selectedBook.title,
                          "author" : selectedBook.author,
                          "coverArt" : selectedBook.thumbNail,
                          "userName" : currentUser.name,
                          "key" : key.key,
                          "userComment" : commentSection.text!,
                          "userRating" : String(describing: ratingSegment.selectedSegmentIndex + 1)
            ]
            databaseRef.child("posts").child(key.key).updateChildValues(values)
        }
        commentSection.text = ""
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let newUrl = (self.apiEndpoint + searchBar.text!).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        APIRequestManager.manager.getData(endPoint: newUrl!) { (data) in
            if let validData = data,
                let validBooks = Book.parseBooks(from: validData) {
                self.booksArray = validBooks
                DispatchQueue.main.async {
                    self.booksCollectionView.reloadData()
                }
            }
        }
        searchBar.text = ""
        commentSection.text = ""
    }
    
    
    
    func createBooksCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 250)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        booksCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        booksCollectionView.delegate = self
        booksCollectionView.dataSource = self
        
        booksCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        let nib = UINib(nibName: bookNibName, bundle:nil)
        booksCollectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
        booksCollectionView.backgroundColor = UIColor.gray
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.booksArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = .green
        selectedBook = booksArray[indexPath.row]
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor =  UIColor.clear
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BookCollectionViewCell
        let aBook = booksArray[indexPath.row]
        

        cell.bookImage.image = nil
        
        cell.bookTitle.text = aBook.title
        APIRequestManager.manager.getData(endPoint: aBook.thumbNail) { (data) in
            if let validData = data {
                let image = UIImage(data: validData)
                DispatchQueue.main.async {
                    cell.bookImage.image = image
                    cell.setNeedsLayout()
                }
            }
        }
        return cell
    }

    //MARK: - Lazy Inits
    
    lazy var ratingSegment: UISegmentedControl = {
       let view = UISegmentedControl(items: ["1","2","3","4","5"])
       view.selectedSegmentIndex = 4
       return view
    }()

    lazy var searchBar: UISearchBar = {
        let view = UISearchBar()
        view.delegate = self
        return view
    }()
    
    lazy var commentSection: UITextView = {
        let view = UITextView()
        view.font = UIFont(name: "Times New Roman", size: 20.0)
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.gray.cgColor
        return view
    }()
    
    }
