//
//  LoginViewController.swift
//  LocalReads
//
//  Created by Tong Lin on 2/18/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit
import SnapKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        setupViewHierarchy()
        configureConstraints()
    }
    
    func setupViewHierarchy(){
        self.view.backgroundColor = .white
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        
        self.view.addSubview(BGImageView)
        self.view.addSubview(containerView)
        containerView.addSubview(logoImageView)
        containerView.addSubview(usernameTextField)
        containerView.addSubview(passwordTextField)
        containerView.addSubview(loginButton)
        self.view.addSubview(resetPasswordButton)
        self.view.addSubview(registerButton)
    }
    
    func loginTapped(){
        
        let feedViewController = FeedViewController()
        let addPostViewController = AddPostViewController()
        let profileViewController = ProfileViewController()
        
        let feedBarItem = UITabBarItem(title: "Feed", image: nil, selectedImage: nil)
        let addBarItem = UITabBarItem(title: "Add", image: nil, selectedImage: nil)
        let profileBarItem = UITabBarItem(title: "Profile", image: nil, selectedImage: nil)
        
        feedViewController.tabBarItem = feedBarItem
        addPostViewController.tabBarItem = addBarItem
        profileViewController.tabBarItem = profileBarItem
        
        let tabView = UITabBarController()
        tabView.viewControllers = [UINavigationController(rootViewController: feedViewController), UINavigationController(rootViewController: addPostViewController), profileViewController]
        tabView.selectedIndex = 0
        self.present(tabView, animated: true, completion: nil)
    }
    
    func configureConstraints(){
        BGImageView.snp.makeConstraints { (view) in
            view.top.leading.trailing.width.equalToSuperview()
            view.height.equalToSuperview().multipliedBy(0.6)
        }
        
        containerView.snp.makeConstraints { (view) in
            view.center.equalToSuperview()
            view.height.equalToSuperview().multipliedBy(0.55)
            view.width.equalToSuperview().multipliedBy(0.8)
        }
        
        logoImageView.snp.makeConstraints { (view) in
            view.size.equalTo(CGSize(width: 200, height: 150))
            view.centerX.equalToSuperview()
            view.top.equalToSuperview().offset(20)
        }
        
        usernameTextField.snp.makeConstraints { (view) in
            view.top.equalTo(logoImageView.snp.bottom).offset(40)
            view.width.equalToSuperview().multipliedBy(0.8)
            view.centerX.equalToSuperview()
        }
        
        passwordTextField.snp.makeConstraints { (view) in
            view.top.equalTo(usernameTextField.snp.bottom).offset(20)
            view.width.equalToSuperview().multipliedBy(0.8)
            view.centerX.equalToSuperview()
        }
        
        loginButton.snp.makeConstraints { (view) in
            view.top.equalTo(passwordTextField.snp.bottom).offset(40)
            view.width.equalToSuperview().multipliedBy(0.6)
            view.centerX.equalToSuperview()
        }
        
        resetPasswordButton.snp.makeConstraints { (view) in
            view.leading.equalTo(containerView.snp.leading)
            view.top.equalTo(containerView.snp.bottom).offset(20)
        }
        
        registerButton.snp.makeConstraints { (view) in
            view.trailing.equalTo(containerView.snp.trailing)
            view.top.equalTo(containerView.snp.bottom).offset(20)
        }
        
    }
    
    //MARK: - Lazy Inits
    lazy var BGImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .yellow
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cyan
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 0.1
        view.alpha = 0.5
        return view
    }()
    
    lazy var logoImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .red
        return view
    }()
    
    lazy var usernameTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Username"
        field.layer.borderWidth = 2.0
        field.layer.borderColor = UIColor.black.cgColor
        return field
    }()
    
    lazy var passwordTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.layer.borderWidth = 2.0
        field.layer.borderColor = UIColor.black.cgColor
        return field
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.isEnabled = true
        button.setTitleColor(.blue, for: .normal)
        button.setTitle("Log in", for: .normal)
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var resetPasswordButton: UIButton = {
        let button = UIButton()
        button.isEnabled = true
        button.setTitleColor(.blue, for: .normal)
        button.setTitle("Forgot password?", for: .normal)
        return button
    }()
    
    lazy var registerButton: UIButton = {
        let button = UIButton()
        button.isEnabled = true
        button.setTitleColor(.blue, for: .normal)
        button.setTitle("Register", for: .normal)
        return button
    }()
}
