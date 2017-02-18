//
//  RegisterNewUserViewController.swift
//  LocalReads
//
//  Created by Tong Lin on 2/18/17.
//  Copyright © 2017 C4Q-3.2. All rights reserved.
//

import UIKit
import Firebase
import SnapKit

class RegisterNewUserViewController: UIViewController, RegisterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewHierarchy()
        configureConstraints()
    }

    func registerTapped(){
        if let email = emailTextField.text, let password = passwordTextField.text {
            registerButton.isEnabled = false
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
                if error != nil {
                    print("error with completion while creating new Authentication: \(error!)")
                }
                if user != nil {
                    // create a new user with the UID
                    // on completion, segue to profile screen
                    self.successfulRegister(username: email, password: password)
                } else {
                    self.showOKAlert(title: "Error", message: error?.localizedDescription)
                }
                self.registerButton.isEnabled = true
            })
        }
    }
    
    func successfulRegister(username: String, password: String){
        self.dismiss(animated: true) {
            self.returnFromRegister(username: username, password: password)
            
        }
    }
    
    func returnFromRegister(username: String, password: String) {
    }
    
    func setupViewHierarchy(){
        self.view.backgroundColor = .white
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        
        self.view.addSubview(profileImageview)
        self.view.addSubview(emailTextField)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(registerButton)
        
    }
    
    func configureConstraints(){
        profileImageview.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.top.equalToSuperview().offset(40)
            view.size.equalTo(CGSize(width: 150, height: 150))
        }
        
        emailTextField.snp.makeConstraints { (view) in
            view.width.equalToSuperview().multipliedBy(0.7)
            view.top.equalTo(profileImageview.snp.bottom).offset(50)
            view.centerX.equalToSuperview()
        }
        
        passwordTextField.snp.makeConstraints { (view) in
            view.width.equalToSuperview().multipliedBy(0.7)
            view.top.equalTo(emailTextField.snp.bottom).offset(50)
            view.centerX.equalToSuperview()
        }
        
        registerButton.snp.makeConstraints { (view) in
            view.width.equalToSuperview().multipliedBy(0.5)
            view.top.equalTo(passwordTextField.snp.bottom).offset(50)
            view.centerX.equalToSuperview()
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
    lazy var profileImageview: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    lazy var emailTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email"
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
    
    lazy var registerButton: UIButton = {
        let button = UIButton()
        button.isEnabled = true
        button.setTitleColor(.blue, for: .normal)
        button.setTitle("Register", for: .normal)
        button.layer.borderWidth = 2.0
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        return button
    }()
    
}
