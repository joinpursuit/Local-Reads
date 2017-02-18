//
//  AddPostViewController.swift
//  LocalReads
//
//  Created by Tong Lin on 2/18/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit

class AddPostViewController: UIViewController, UISearchBarDelegate,  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var booksArray: [Book] = []
    var booksCollectionView: UICollectionView!
    var reuseIdentifier = "bookCell"
    var bookNibName = "BookCollectionViewCell"
    var apiEndpoint = "https://www.googleapis.com/books/v1/volumes?q="
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "What Book Have You Read"
        setupViewHierarchy()
        configureConstraints()
        // Do any additional setup after loading the view.
    }

    func setupViewHierarchy(){
        self.view.backgroundColor = .white
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        createBooksCollectionView()
        
        self.view.addSubview(searchBar)
        self.view.addSubview(booksCollectionView)
    }
    
    func configureConstraints(){
        searchBar.snp.makeConstraints { (view) in
            view.top.equalTo(self.topLayoutGuide.snp.bottom)
            view.leading.trailing.equalToSuperview()
            //view.height.equalTo(40.0)
        }
        booksCollectionView.snp.makeConstraints { (view) in
            view.top.equalTo(searchBar.snp.bottom).offset(10.0)
            view.leading.trailing.equalToSuperview()
            view.height.equalTo(175.0)
        }
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
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
    }
    
    func createBooksCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 125, height: 175)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        booksCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        booksCollectionView.delegate = self
        booksCollectionView.dataSource = self
        
        booksCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        let nib = UINib(nibName: bookNibName, bundle:nil)
        booksCollectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
        booksCollectionView.backgroundColor = .white
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.booksArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BookCollectionViewCell
        let aBook = booksArray[indexPath.row]
        
        cell.bookImage.image = nil
        
        APIRequestManager.manager.getData(endPoint: aBook.thumbNail) { (data) in
            if let validData = data {
                let image = UIImage(data: validData)
                cell.bookImage.image = image
                cell.setNeedsLayout()
            }
        }
        
        return cell
    }



    //MARK: - Lazy Inits
    lazy var searchBar: UISearchBar = {
        let view = UISearchBar()
        view.delegate = self
        view.showsCancelButton = true
        return view
    }()

    
    }
