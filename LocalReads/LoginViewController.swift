//
//  LoginViewController.swift
//  LocalReads
//
//  Created by Tong Lin on 2/18/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewHierarchy()
        configureConstraints()
    }
    
    func setupViewHierarchy(){
        self.view.backgroundColor = .lightGray
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        
        self.view.addSubview(BGImageView)
        self.view.addSubview(containerView)
        containerView.addSubview(filterView)
        containerView.addSubview(logoImageView)
        containerView.addSubview(usernameTextField)
        containerView.addSubview(passwordTextField)
        containerView.addSubview(loginButton)
        self.view.addSubview(resetPasswordButton)
        self.view.addSubview(registerButton)
    }
    
    func loginTapped(){
        print("Log in")
        if let username = usernameTextField.text,
            let password = passwordTextField.text{
            loginCurrentUser(username: username, password: password)
        }
    }
    
    func loginCurrentUser(username: String, password: String){
        self.loginButton.isEnabled = false
        FIRAuth.auth()?.signIn(withEmail: username, password: password, completion: { (user: FIRUser?, error: Error?) in
            if error != nil {
                print("Erro \(error)")
            }
            if user != nil {
                print("SUCCESS.... \(user!.uid)")
                self.successfullyLogin()
            } else {
                self.showOKAlert(title: "Error", message: error?.localizedDescription)
            }
            self.loginButton.isEnabled = true
        })
    }
    
    func successfullyLogin(){
        let feedViewController = UINavigationController(rootViewController: FeedViewController())
        let addPostViewController = UINavigationController(rootViewController: AddPostViewController())
        let profileViewController = ProfileViewController()
        
        let feedBarItem = UITabBarItem(title: "Feed", image: nil, selectedImage: nil)
        let addBarItem = UITabBarItem(title: "Add", image: nil, selectedImage: nil)
        let profileBarItem = UITabBarItem(title: "Profile", image: nil, selectedImage: nil)
        
        feedViewController.tabBarItem = feedBarItem
        addPostViewController.tabBarItem = addBarItem
        profileViewController.tabBarItem = profileBarItem
        
        let tabView = UITabBarController()
        tabView.viewControllers = [feedViewController, addPostViewController, profileViewController]
        tabView.selectedIndex = 0
        self.present(tabView, animated: true, completion: nil)
        
    }
    
    func configureConstraints(){
        BGImageView.snp.makeConstraints { (view) in
            view.top.leading.trailing.width.equalToSuperview()
            view.height.equalToSuperview().multipliedBy(0.45)
        }
        
        containerView.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.centerY.equalToSuperview().offset(-30)
            view.height.equalToSuperview().multipliedBy(0.4)
            view.width.equalToSuperview().multipliedBy(0.8)
        }
        
        filterView.snp.makeConstraints { (view) in
            view.top.bottom.leading.trailing.equalToSuperview()
        }
        
        logoImageView.snp.makeConstraints { (view) in
            view.size.equalTo(CGSize(width: 200, height: 150))
            view.centerX.equalToSuperview()
            view.centerY.equalTo(containerView.snp.top)
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
            view.top.equalTo(containerView.snp.bottom).offset(10)
        }
        
        registerButton.snp.makeConstraints { (view) in
            view.trailing.equalTo(containerView.snp.trailing)
            view.top.equalTo(containerView.snp.bottom).offset(10)
        }
        
    }
    
    //MARK: - Helper func
    func showOKAlert(title: String, message: String?, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: completion)
    }
    
    //MARK: - Lazy Inits
    lazy var BGImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "Blue-dotted-background")
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var filterView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.4
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
        field.font = UIFont.systemFont(ofSize: 18)
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.black.cgColor
        return field
    }()
    
    lazy var passwordTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.font = UIFont.systemFont(ofSize: 18)
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.black.cgColor
        return field
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.isEnabled = true
        button.setTitleColor(.blue, for: .normal)
        button.setTitle("Log in", for: .normal)
        button.layer.borderWidth = 2.0
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var resetPasswordButton: UIButton = {
        let button = UIButton()
        button.isEnabled = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.setTitleColor(.blue, for: .normal)
        button.setTitle("Forgot password?", for: .normal)
        return button
    }()
    
    lazy var registerButton: UIButton = {
        let button = UIButton()
        button.isEnabled = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.setTitleColor(.blue, for: .normal)
        button.setTitle("Register", for: .normal)
        return button
    }()
}
