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
    
    static var currentUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.text = "vinny@vinny.com"
        passwordTextField.text = "foobar123"
        
        setupViewHierarchy()
        configureConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let animator = UIViewPropertyAnimator(duration: 0.8, curve: .easeIn, animations: nil)
        
        logoImageView.alpha = 0.3
        logoImageView.snp.removeConstraints()
        logoImageView.snp.remakeConstraints { (view) in
            view.size.equalTo(CGSize(width: 200, height: 150))
            view.centerX.equalToSuperview()
            view.centerY.equalTo(containerView.snp.top)
        }
        
        animator.addAnimations {
            self.logoImageView.alpha = 1.0
            self.containerView.layoutIfNeeded()
        }
        
        animator.startAnimation()
    }
    
    override func viewDidLayoutSubviews() {
        let border1 = CALayer()
        let width = CGFloat(2.0)
        border1.borderColor = ColorManager.shared.primaryDark.cgColor
        border1.frame = CGRect(x: 0, y: emailTextField.frame.size.height - width, width:  emailTextField.frame.size.width, height: emailTextField.frame.size.height)
        border1.borderWidth = width
        emailTextField.layer.addSublayer(border1)
        
        let border2 = CALayer()
        border2.borderColor = ColorManager.shared.primaryDark.cgColor
        border2.frame = CGRect(x: 0, y: passwordTextField.frame.size.height - width, width:  passwordTextField.frame.size.width, height: passwordTextField.frame.size.height)
        border2.borderWidth = width
        passwordTextField.layer.addSublayer(border2)
        
        let border3 = CALayer()
        border3.borderColor = ColorManager.shared.primaryDark.cgColor
        border3.frame = CGRect(x: 0, y: nameTextField.frame.size.height - width, width:  nameTextField.frame.size.width, height: nameTextField.frame.size.height)
        border3.borderWidth = width
        nameTextField.layer.addSublayer(border3)
    }
    
    func setupViewHierarchy(){
        self.view.backgroundColor = ColorManager.shared.primaryLight
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        
        nameTextField.isHidden = true
        
        self.view.addSubview(BGImageView)
        self.view.addSubview(containerView)
        containerView.addSubview(filterView)
        containerView.addSubview(logoImageView)
        containerView.addSubview(modeSwitch)
        containerView.addSubview(emailTextField)
        containerView.addSubview(nameTextField)
        containerView.addSubview(passwordTextField)
        containerView.addSubview(logAndRegButton)
        containerView.addSubview(resetPasswordButton)
        self.view.addSubview(memoLabel)
        
    }
    
    func switchForm(sender: UISegmentedControl){
        switch sender.selectedSegmentIndex{
        case 0:
            registerNewUser(type: "Log in")
        default:
            registerNewUser(type: "Register")
        }
    }
    
    func registerNewUser(type: String){
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeIn, animations: nil)
        
        if modeSwitch.selectedSegmentIndex == 0{
            animator.addAnimations {
                self.nameTextField.isHidden = true
                self.nameTextField.snp.remakeConstraints({ (view) in
                    view.center.equalToSuperview()
                    view.size.equalTo(CGSize(width: 1, height: 1))
                })
                
                self.passwordTextField.snp.remakeConstraints { (view) in
                    view.top.equalTo(self.emailTextField.snp.bottom).offset(15)
                    view.width.equalToSuperview().multipliedBy(0.8)
                    view.centerX.equalToSuperview()
                }
                
                self.emailTextField.text = "demo@hahaha.com"
                self.passwordTextField.text = "000000"
                
                self.containerView.layoutIfNeeded()
            }
        }else{
            animator.addAnimations {
                self.nameTextField.isHidden = false
                self.nameTextField.snp.remakeConstraints({ (view) in
                    view.top.equalTo(self.emailTextField.snp.bottom).offset(15)
                    view.width.equalToSuperview().multipliedBy(0.8)
                    view.centerX.equalToSuperview()
                })
                
                self.passwordTextField.snp.remakeConstraints { (view) in
                    view.top.equalTo(self.nameTextField.snp.bottom).offset(15)
                    view.width.equalToSuperview().multipliedBy(0.8)
                    view.centerX.equalToSuperview()
                }
                
                self.emailTextField.text = ""
                self.nameTextField.text = ""
                self.passwordTextField.text = ""
                
                self.containerView.layoutIfNeeded()
            }
        }
        
        animator.addCompletion { (position) in
            self.logAndRegButton.setTitle(type, for: .normal)
        }
        
        animator.startAnimation()
    }
    
    func iamTapped(){
        print("Log in")
        animateButton(sender: logAndRegButton)
        
        switch modeSwitch.selectedSegmentIndex {
        case 0:
            if let username = emailTextField.text,
                let password = passwordTextField.text{
                loginCurrentUser(username: username, password: password)
            }
        default:
            if let email = emailTextField.text, let name = nameTextField.text, let password = passwordTextField.text {
                FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
                    if error != nil {
                        print("error with completion while creating new Authentication: \(error!)")
                    }
                    if user != nil {
                        // create a new user with the UID
                        // on completion, segue to profile screen
                        
                        self.getRandomImage(completion: { (image) in
                            if let validImage = image{
                                User.updateUserProfileImage(uid: (user?.uid)!, image: validImage, completion: { (error) in
                                    //error checking
                                    if error != nil{
                                        print(error!.localizedDescription)
                                    }
                                })
                            }
                        })
                        
                        User.createUserInDatabase(email: email, name: name, profileImage: (user?.uid)!, currentLibrary: "", completion: {
                            self.loginCurrentUser(username: email, password: password)
                        })
                        
                    } else {
                        self.showOKAlert(title: "Error", message: error?.localizedDescription)
                    }
                })
            }
        }
    }
    
    func updateCurrentUser(id: String){
        let reference = FIRDatabase.database().reference().child("users")
        
        reference.child(id).observe(.value, with: { (snapshot) in
            if let snap = snapshot.value as? NSDictionary,
                let email = snap["email"] as? String,
                let name = snap["name"] as? String,
                let profileImage = snap["profileImage"] as? String,
                let currentLibrary = snap["currentLibrary"] as? String {
                
                LoginViewController.currentUser = User(email: email, name: name, profileImage: profileImage, currentLibrary: currentLibrary)
                
            }else{
                print("error parsing current user")
            }
        })
    }
    
    func loginCurrentUser(username: String, password: String){
        self.logAndRegButton.isEnabled = false
        FIRAuth.auth()?.signIn(withEmail: username, password: password, completion: { (user: FIRUser?, error: Error?) in
            if error != nil {
                print("Erro \(error)")
            }
            if user != nil {
                print("SUCCESS.... \(user!.uid)")
                
                self.updateCurrentUser(id: user!.uid)
                self.successfullyLogin()
            } else {
                self.showOKAlert(title: "Error", message: error?.localizedDescription)
            }
            self.logAndRegButton.isEnabled = true
        })
    }
    
    func successfullyLogin(){
        let feedViewController = UINavigationController(rootViewController: FeedViewController())
        let profileViewController = UINavigationController(rootViewController: ProfileViewController())
        

        let feedBarItem = UITabBarItem(title: "", image: UIImage(named: "gallery_icon"), selectedImage: nil)
        let profileBarItem = UITabBarItem(title: "", image: UIImage(named: "user_icon"), selectedImage: nil)
        
        feedViewController.tabBarItem = feedBarItem
        profileViewController.tabBarItem = profileBarItem
        
        let tabView = UITabBarController()
        tabView.tabBar.tintColor = ColorManager.shared.accent

        tabView.viewControllers = [feedViewController, profileViewController]
        tabView.selectedIndex = 0
        self.present(tabView, animated: true, completion: nil)
        
    }
    
    func configureConstraints(){
        BGImageView.snp.makeConstraints { (view) in
            view.top.leading.trailing.width.equalToSuperview()
            view.height.equalToSuperview().multipliedBy(0.85)
        }
        
        containerView.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.centerY.equalToSuperview().offset(30)
            view.height.equalToSuperview().multipliedBy(0.55)
            view.width.equalToSuperview().multipliedBy(0.8)
        }
        
        filterView.snp.makeConstraints { (view) in
            view.top.bottom.leading.trailing.equalToSuperview()
        }
        
        logoImageView.snp.makeConstraints { (view) in
            view.size.equalTo(CGSize(width: 0, height: 0))
            view.centerX.equalToSuperview()
            view.centerY.equalTo(containerView.snp.top)
        }
        
        modeSwitch.snp.makeConstraints { (view) in
            view.top.equalTo(logoImageView.snp.bottom).offset(40)
            view.width.equalToSuperview().multipliedBy(0.8)
            view.centerX.equalToSuperview()
        }
        
        emailTextField.snp.makeConstraints { (view) in
            view.top.equalTo(modeSwitch.snp.bottom).offset(20)
            view.width.equalToSuperview().multipliedBy(0.8)
            view.centerX.equalToSuperview()
        }
        
        nameTextField.snp.makeConstraints { (view) in
            view.center.equalToSuperview()
            view.size.equalTo(CGSize(width: 1, height: 1))
        }
        
        passwordTextField.snp.makeConstraints { (view) in
            view.top.equalTo(emailTextField.snp.bottom).offset(15)
            view.width.equalToSuperview().multipliedBy(0.8)
            view.centerX.equalToSuperview()
        }
        
        logAndRegButton.snp.makeConstraints { (view) in
            view.top.equalTo(passwordTextField.snp.bottom).offset(35)
            view.width.equalToSuperview().multipliedBy(0.6)
            view.centerX.equalToSuperview()
        }
        
        resetPasswordButton.snp.makeConstraints { (view) in
            view.leading.equalToSuperview().offset(5)
            view.bottom.equalToSuperview().offset(-5)
        }
        
        memoLabel.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.top.equalTo(BGImageView.snp.bottom)
            view.bottom.equalToSuperview()
        }
    }
    
    //MARK: - Helper func
    internal func showOKAlert(title: String, message: String?, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: completion)
    }
    
    internal func getRandomImage(completion: @escaping (UIImage?)->Void){
        let randomNum = Int(arc4random_uniform(9))
        let str = "https://randomuser.me/api/portraits/lego/\(randomNum).jpg"
        APIRequestManager.manager.getData(endPoint: str) { (data) in
            if data != nil{
                completion(UIImage(data: data!))
            }else{
                print("Wrong image url, no image data return.")
                completion(nil)
            }
        }
    }
    
    internal func animateButton(sender: UIButton) {
        let newTransform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        let originalTransform = sender.imageView!.transform
        UIView.animate(withDuration: 0.1, animations: {
            sender.layer.transform = CATransform3DMakeAffineTransform(newTransform)
        }, completion: { (complete) in
            sender.layer.transform = CATransform3DMakeAffineTransform(originalTransform)
        })
    }
    
    //MARK: - Lazy Inits
    lazy var BGImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = ColorManager.shared.primary
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.8
        view.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.layer.shadowRadius = 6
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
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "book_icon")
        return view
    }()
    
    lazy var modeSwitch: UISegmentedControl = {
        let view = UISegmentedControl()
        view.insertSegment(withTitle: "Log in", at: 0, animated: true)
        view.insertSegment(withTitle: "Register", at: 1, animated: true)
        view.tintColor = .white
        view.selectedSegmentIndex = 0
        view.addTarget(self, action: #selector(switchForm), for: .valueChanged)
        return view
    }()
    
    lazy var emailTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email"
        field.font = UIFont.systemFont(ofSize: 18)
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.layer.masksToBounds = true
        return field
    }()
    
    lazy var nameTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Your name"
        field.font = UIFont.systemFont(ofSize: 18)
        field.autocorrectionType = .no
        field.layer.masksToBounds = true
        field.autocapitalizationType = .none
        return field
    }()
    
    lazy var passwordTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.font = UIFont.systemFont(ofSize: 18)
        field.isSecureTextEntry = true
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.layer.masksToBounds = true
        return field
    }()
    
    lazy var logAndRegButton: UIButton = {
        let button = UIButton()
        button.isEnabled = true
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle("Log in", for: .normal)
        button.layer.borderWidth = 2.0
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(iamTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var resetPasswordButton: UIButton = {
        let button = UIButton()
        button.isEnabled = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle("Forgot password?", for: .normal)
        return button
    }()
    
    lazy var memoLabel: UILabel = {
        let label = UILabel()
        label.text = "Let's read together."
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.8
        label.layer.shadowOffset = CGSize(width: 0, height: 5)
        label.layer.shadowRadius = 5
        return label
    }()
}

