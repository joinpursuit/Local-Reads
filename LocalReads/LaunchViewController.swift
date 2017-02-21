//
//  LaunchViewController.swift
//  LocalReads
//
//  Created by Tong Lin on 2/21/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit
import SnapKit
import ImageIO

class LaunchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { (view) in
            view.top.bottom.leading.trailing.equalToSuperview()
        }
        
        imageView.loadGif(name: "giphy")
    }

    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            let login = LoginViewController()
            login.modalTransitionStyle = .crossDissolve
            login.modalPresentationStyle = .overCurrentContext
            self.present(login, animated: true, completion: nil)
        }
    }
    

    lazy var imageView: UIImageView = {
        let view = UIImageView()
        
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
}

