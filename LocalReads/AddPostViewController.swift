//
//  AddPostViewController.swift
//  LocalReads
//
//  Created by Tong Lin on 2/18/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit
import Firebase
import Cosmos

class AddPostViewController: UIViewController, UISearchBarDelegate,  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate {

    var booksArray: [Book] = []
    var booksCollectionView: UICollectionView!
    var reuseIdentifier = "bookCell"
    var bookNibName = "BookCollectionViewCell"
    var apiEndpoint = "https://www.googleapis.com/books/v1/volumes?q="
    var selectedBook: Book!
    var scrollView = UIScrollView()
    var otherView = UIView()
    var activeField: UITextField?

    
    //Will Attempt To Get Stars System
    var ratingTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotifications()
        self.navigationItem.title = "What Book Have You Read"
        setupViewHierarchy()
        configureConstraints()
        if booksArray.count == 0 {
            noResultsLabel.isHidden = false
        }
        
        starRating.settings.starSize = Double((self.view.frame.width - (28*4))/5)
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        
        if let info = notification.userInfo,
            let sizeString = info[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
        
            
            //scrollView.setContentOffset(CGPoint(x:0, y: 600), animated: false)
            
            let keyboardSize = sizeString.cgRectValue
        
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            
            scrollView.contentInset = contentInsets
            
            scrollView.scrollIndicatorInsets = contentInsets
            var rect = self.view.frame
            
            rect.size.height -= keyboardSize.height
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero;
        scrollView.scrollIndicatorInsets = .zero;
    }


    func setupViewHierarchy(){
        self.view.backgroundColor = ColorManager.shared.primaryLight
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        createBooksCollectionView()
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(otherView)
        self.otherView.addSubview(searchBar)
        self.otherView.addSubview(booksCollectionView)
        self.otherView.addSubview(noResultsLabel)
        self.otherView.addSubview(starRating)
        self.otherView.addSubview(commentSection)
        self.otherView.addSubview(floatingButton)
        self.otherView.addSubview(cancelButton)
        
        scrollView.isScrollEnabled = true
        scrollView.contentSize = otherView.frame.size
        scrollView.keyboardDismissMode = .interactive
        
        setTextView()
        
    }
    
    func configureConstraints(){
        
        scrollView.snp.makeConstraints { (view) in
            view.trailing.leading.equalToSuperview()
            view.top.equalTo(self.topLayoutGuide.snp.bottom)
            view.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        }
        
        otherView.snp.makeConstraints { (view) in
        view.leading.trailing.top.bottom.height.width.equalToSuperview()
        }
        
        
        searchBar.snp.makeConstraints { (view) in
            view.width.equalToSuperview()
            view.top.equalTo(scrollView.snp.top)
            view.height.equalTo(30)
        }
        
        booksCollectionView.snp.makeConstraints { (view) in
            view.width.equalToSuperview()
            view.centerX.equalToSuperview()
            view.bottom.equalTo(starRating.snp.top).offset(-8.0)
            view.height.equalTo(330.0)
        }
        
        noResultsLabel.snp.makeConstraints { (view) in
            view.trailing.leading.top.bottom.equalTo(booksCollectionView)
        }
        
        starRating.snp.makeConstraints { (view) in
            view.bottom.equalTo(commentSection.snp.top).offset(-8.0)
            view.width.equalToSuperview()
            view.centerX.equalToSuperview()
            view.height.equalTo(65)
        }

        commentSection.snp.makeConstraints { (view) in
            view.bottom.equalToSuperview().inset(8.0)
            view.leading.equalToSuperview().offset(8.0)
            view.trailing.equalToSuperview().inset(8.0)
            view.height.equalTo(150.0)
        }
        
        floatingButton.snp.makeConstraints { (view) in
            view.width.height.equalTo(54)
            view.trailing.bottom.equalToSuperview().offset(-20)
        }
        
        cancelButton.snp.makeConstraints { (view) in
            view.width.height.equalTo(54)
            view.bottom.equalToSuperview().offset(-20)
            view.leading.equalToSuperview().offset(20)
        }

    }
    
    
    func didTapUpload() {
        guard selectedBook != nil else { return print("Pick a book bruh") }
        
        let databaseRef = FIRDatabase.database().reference()
        print(123)
        let key = databaseRef.childByAutoId()
        
        if let currentUser = LoginViewController.currentUser {
            let values = ["bookTitle" : selectedBook.title,
                          "bookAuthor" : selectedBook.author,
                          "bookImageURL" : selectedBook.thumbNail,
                          "userName" : currentUser.name,
                          "userID" : FIRAuth.auth()!.currentUser!.uid,
                          "key" : key.key,
                          "userComment" : commentSection.text!,
                          "userRating" : Int(starRating.rating),
                          "libraryName" : currentUser.currentLibrary
            ] as [String : Any]
            databaseRef.child("posts").child(key.key).updateChildValues(values, withCompletionBlock: { (error: Error?, reference: FIRDatabaseReference?) in
                if error != nil {
                    print(error!)
                } else {
//                let alert = UIAlertController(title: "Complete!", message: "Upload Complete!", preferredStyle: .alert)
//                let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                alert.addAction(ok)
//                self.present(alert, animated: true, completion: nil)
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
        commentSection.text = ""
        starRating.rating = 1.0
    }
    
    func didTapCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let newUrl = (self.apiEndpoint + searchBar.text!).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        APIRequestManager.manager.getData(endPoint: newUrl!) { (data) in
            if let validData = data,
                let validBooks = Book.parseBooks(from: validData) {
                DispatchQueue.main.async {
                    self.booksArray = validBooks
                    if self.booksArray.isEmpty {
                        self.noResultsLabel.isHidden = false
                    } else {
                        self.noResultsLabel.isHidden = true
                    }
                self.booksCollectionView.reloadData()
                self.booksCollectionView.contentOffset.x = 0
               }
            }
        }
        searchBar.text = ""
        commentSection.text = ""
        searchBar.resignFirstResponder()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == booksCollectionView {
            
            for _ in booksCollectionView.visibleCells {
                let indexPath = self.booksCollectionView.indexPathsForVisibleItems
                booksCollectionView.scrollToItem(at: indexPath[1], at: .centeredHorizontally, animated: false)
            }
        }
    }
    
    func createBooksCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 230, height: 330)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        
        booksCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        booksCollectionView.delegate = self
        booksCollectionView.dataSource = self
        
        booksCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        let nib = UINib(nibName: bookNibName, bundle:nil)
        booksCollectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
        booksCollectionView.backgroundColor = ColorManager.shared.primaryLight

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.booksArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = ColorManager.shared.accent
        selectedBook = booksArray[indexPath.row]
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
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
        
        if aBook.thumbNail == "" {
            cell.bookImage.image = #imageLiteral(resourceName: "missingbook")
        } else {
        APIRequestManager.manager.getData(endPoint: aBook.thumbNail) { (data) in
            if let validData = data {
                let image = UIImage(data: validData)
                DispatchQueue.main.async {
                    cell.bookImage.image = image
                    cell.setNeedsLayout()
                }
            }
            }
        }
        return cell
    }

    //MARK: - Text View Delegates
    func setTextView() {
        commentSection.delegate = self
        commentSection.text = "Add a description..."
        commentSection.textColor = UIColor.lightGray
        }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
    scrollView.setContentOffset(CGPoint(x:0, y: 250), animated: false)

        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add a description..."
            textView.textColor = UIColor.lightGray
        }
        view.endEditing(true)
    }
    
    
    //MARK: - Lazy Inits

    
    lazy var starRating: CosmosView = {
        let view = CosmosView()
        view.rating = 1.0
        view.settings.fillMode = .full
        view.settings.starSize = 60
        view.settings.starMargin = 28
        view.didFinishTouchingCosmos = { (rating) in
         print(rating)
        }
        view.settings.filledColor = ColorManager.shared.accent
        view.settings.emptyBorderColor = ColorManager.shared.accent
        view.settings.filledBorderColor = ColorManager.shared.accent
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
    
    internal lazy var floatingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(didTapUpload), for: .touchUpInside)
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
    
    internal lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        button.setImage(UIImage(named: "x_symbol")!, for: .normal)
        button.backgroundColor = ColorManager.shared.accent
        button.layer.cornerRadius = 26
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.8
        button.layer.shadowOffset = CGSize(width: 0, height: 5)
        button.layer.shadowRadius = 5
        button.clipsToBounds = false
        return button
    }()

    
    lazy var noResultsLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        view.backgroundColor = ColorManager.shared.primary
        view.text = "Search for a book to share\n in the search bar above."
        view.textColor = .white
        view.textAlignment = .center
        view.isHidden = true
        return view
    }()

    
    lazy var uploadButton: UIButton = {
    let button = UIButton()
    button.setBackgroundImage(#imageLiteral(resourceName: "Button-Up-512"), for: .normal)
    button.addTarget(self, action: #selector(didTapUpload), for: .touchUpInside)
    button.snp.makeConstraints { (view) in
    view.width.height.equalTo(35.0)
        }
    return button
    }()
    
    
        
}
