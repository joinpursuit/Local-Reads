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

class RegisterNewUserViewController: UIViewController {

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
                    User.createUserInDatabase(email: email, name: self.nameTextField.text ?? "", profileImage: (user?.uid)!, currentLibrary: "Queens Library", completion: {
                        self.successfulRegister(username: email, password: password)
                    })
                } else {
                    self.showOKAlert(title: "Error", message: error?.localizedDescription)
                }
                self.registerButton.isEnabled = true
            })
        }
    }
    
    func backTapped(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func successfulRegister(username: String, password: String){
        let viewC = presentingViewController as? LoginViewController
        
        self.dismiss(animated: true) {
            viewC?.usernameTextField.text = username
            viewC?.passwordTextField.text = password
            viewC?.loginTapped()
        }
    }
    
    func setupViewHierarchy(){
        self.view.backgroundColor = .white
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        
        self.view.addSubview(backButton)
        self.view.addSubview(profileImageview)
        self.view.addSubview(emailTextField)
        self.view.addSubview(nameTextField)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(registerButton)
        
    }
    
    func configureConstraints(){
        backButton.snp.makeConstraints { (view) in
            view.top.leading.equalToSuperview().offset(20)
        }
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
        
        nameTextField.snp.makeConstraints { (view) in
            view.width.equalToSuperview().multipliedBy(0.7)
            view.top.equalTo(emailTextField.snp.bottom).offset(50)
            view.centerX.equalToSuperview()
        }
        
        passwordTextField.snp.makeConstraints { (view) in
            view.width.equalToSuperview().multipliedBy(0.7)
            view.top.equalTo(nameTextField.snp.bottom).offset(50)
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
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.layer.borderColor = UIColor.black.cgColor
        return field
    }()
    
    lazy var nameTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Your name"
        field.font = UIFont.systemFont(ofSize: 18)
        field.layer.borderWidth = 1.0
        field.autocorrectionType = .no
        field.autocapitalizationType = .words
        field.layer.borderColor = UIColor.black.cgColor
        return field
    }()
    
    lazy var passwordTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.font = UIFont.systemFont(ofSize: 18)
        field.isSecureTextEntry = true
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
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
    
    lazy var backButton: UIButton = {
        let button = UIButton()
        button.isEnabled = true
        button.setTitleColor(.blue, for: .normal)
        button.setTitle("<Back", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return button
    }()
    
}
