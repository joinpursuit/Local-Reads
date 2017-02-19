//
//  LibraryFilterViewController.swift
//  LocalReads
//
//  Created by Tom Seymour on 2/18/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit
import SnapKit


enum LibraryViewStyle {
    case fromFeed
    case fromProfile
}

class LibraryFilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var libraries: [Library] = []
    
    var selectedLibrary: Library?
    
    var viewStyle: LibraryViewStyle!
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .yellow
        // Do any additional setup after loading the view.
        
        setViews()
        setConstraints()
        getLibraries()
        
        setNavBar()
    }
    
    func setNavBar() {
        if self.viewStyle == LibraryViewStyle.fromFeed {
            let allButton = UIBarButtonItem(title: "All Libraries", style: .done, target: self, action: #selector(allLibrairesTapped))
            self.navigationItem.rightBarButtonItem = allButton
        }
    }
    
    func setViews() {
        tableview.delegate = self
        tableview.dataSource = self
        tableview.backgroundColor = ColorManager.shared.primaryLight
        self.view.addSubview(tableview)
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "libraryTableViewCell")
    }
    
    func setConstraints() {
        self.edgesForExtendedLayout = []
        
        self.tableview.snp.makeConstraints { (view) in
            view.top.bottom.leading.trailing.equalToSuperview()
        }
    }

    func getLibraries() {
        APIRequestManager.manager.getData(endPoint: "https://data.cityofnewyork.us/resource/b67a-vkqb.json") { (data) in
            if let data = data {
                if let libraries = Library.getLibraries(from: data) {
                    self.libraries = libraries.sorted { $0.name < $1.name }
                    DispatchQueue.main.async {
                        self.tableview.reloadData()
                    }
                }
            }
        }
    }
    
  
    //MARK: - TableView Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return libraries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "libraryTableViewCell", for: indexPath)
        cell.textLabel?.text = libraries[indexPath.row].name
        cell.textLabel?.textColor = .white
            cell.backgroundColor = ColorManager.shared.colorArray[indexPath.row % ColorManager.shared.colorArray.count]

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedLibrary = libraries[indexPath.row]
        
        if self.viewStyle == LibraryViewStyle.fromFeed {
            FeedViewController.libraryToFilterBy = libraries[indexPath.row]
        } else {
            ProfileViewController.chosenLibrary = libraries[indexPath.row]
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Actions
    
    func allLibrairesTapped() {
        self.selectedLibrary = nil
        FeedViewController.libraryToFilterBy = nil
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Lazy vars

    lazy var tableview: UITableView = {
       let view = UITableView()
        return view
    }()
    
}
