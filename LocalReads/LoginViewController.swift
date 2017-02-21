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
    var loadingViews: [UIView] = []
    let animator = UIViewPropertyAnimator(duration: 0.6, curve: .easeIn, animations: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.text = "vinny@vinny.com"
        passwordTextField.text = "foobar123"
        
        setupViewHierarchy()
        configureConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        logoImageView.alpha = 0.3
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
    
    override func viewDidDisappear(_ animated: Bool) {
        self.removeAllDot()
    }
    
    override func viewDidLayoutSubviews() {
        let width = CGFloat(2.0)
        
        let _ = [emailTextField, passwordTextField, nameTextField].map { current in
            let border = CALayer()
            border.borderColor = ColorManager.shared.primaryDark.cgColor
            border.frame = CGRect(x: 0, y: current.frame.size.height - width, width:  current.frame.size.width, height: current.frame.size.height)
            border.borderWidth = width
            current.layer.addSublayer(border)
        }
    }
    
    func setupViewHierarchy(){
        self.view.backgroundColor = ColorManager.shared.primaryLight
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        
        nameTextField.isHidden = true
        loadingContainer.isHidden = true
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
        self.view.addSubview(loadingContainer)
        
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
        //Preloading animation start here
        animateButton(sender: logAndRegButton)
        preloadAnimator {
            switch self.modeSwitch.selectedSegmentIndex {
            case 0:
                if let username = self.emailTextField.text,
                    let password = self.passwordTextField.text{
                    self.loginCurrentUser(username: username, password: password)
                }
            default:
                if let email = self.emailTextField.text, let name = self.nameTextField.text, let password = self.passwordTextField.text {
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
        
        loadingContainer.snp.makeConstraints { (view) in
            view.center.equalToSuperview()
            view.height.width.equalToSuperview().multipliedBy(0)
        }
    }
    
    //MARK: - Helper func
    internal func showOKAlert(title: String, message: String?, completion: (() -> Void)? = nil) {
        self.removeAllDot()
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
        view.tintColor = ColorManager.shared.accent
        view.selectedSegmentIndex = 0
        view.addTarget(self, action: #selector(switchForm), for: .valueChanged)
        return view
    }()
    
    lazy var emailTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email"
        field.textColor = .white
        field.font = UIFont.systemFont(ofSize: 18)
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.layer.masksToBounds = true
        return field
    }()
    
    lazy var nameTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Your name"
        field.textColor = .white
        field.font = UIFont.systemFont(ofSize: 18)
        field.autocorrectionType = .no
        field.layer.masksToBounds = true
        field.autocapitalizationType = .none
        return field
    }()
    
    lazy var passwordTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.textColor = .white
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
        button.setTitleColor(ColorManager.shared.accent, for: .normal)
        button.setTitle("Log in", for: .normal)
        button.layer.borderWidth = 2.0
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.borderColor = ColorManager.shared.accent.cgColor
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
    
    lazy var loadingContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.3
        return view
    }()
}

extension LoginViewController{
    //preloading animation
    
    func preloadAnimator(completion: @escaping ()-> Void){
        loadingContainer.isHidden = false
        loadingContainer.snp.remakeConstraints { (view) in
            view.center.equalToSuperview()
            view.width.equalToSuperview()
            view.height.equalToSuperview().multipliedBy(0.3)
        }
        
        self.animator.addAnimations {
            self.loadingViews = []
            let sizeArr: [CGFloat] = [20, 17, 14, 11, 8]
            let colorArr = ColorManager.shared.colorArray
            for index in 0..<sizeArr.count{
                DispatchQueue.main.asyncAfter(deadline: .now()+Double(index)/6, execute: {
                    self.addAnimateLayer(size: sizeArr[index], dotColor: colorArr[6+index])
                })
            }
            self.view.layoutIfNeeded()
        }
        
        self.animator.addCompletion { (_) in
            DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                completion()
            })
        }
        
        animator.startAnimation()
    }
    
    func addAnimateLayer(size: CGFloat, dotColor: UIColor){
        self.loadingViews.append(self.viewWithCircle(size: size, dotColor: dotColor))
        
        self.view.addSubview(self.loadingViews.last!)
        self.loadingViews.last?.snp.makeConstraints({ (view) in
            view.center.equalToSuperview()
            view.size.equalTo(CGSize(width: 100, height: 100))
        })
        self.view.layoutIfNeeded()
        
        let animate = CABasicAnimation(keyPath: "transform.rotation")
        animate.duration = 1.5
        animate.repeatCount = 1
        animate.fromValue = 0.0
        animate.toValue = Float(Float.pi * 2.0)
        self.loadingViews.last?.layer.add(animate, forKey: nil)
        
    }
    
    func viewWithCircle(size: CGFloat, dotColor: UIColor) -> UIView{
        let dot = UIView()
        dot.layer.cornerRadius = size/2
        dot.backgroundColor = dotColor
        
        let myView = UIView()
        myView.layer.cornerRadius = 50
        myView.backgroundColor = .clear
        myView.addSubview(dot)
        dot.snp.makeConstraints { (view) in
            view.top.centerX.equalToSuperview()
            view.size.equalTo(CGSize(width: size, height: size))
        }
        
        return myView
    }
    
    func removeAllDot(){
        loadingContainer.isHidden = true
        loadingContainer.snp.remakeConstraints { (view) in
            view.center.equalToSuperview()
            view.height.width.equalToSuperview().multipliedBy(0)
        }
        
        let _ = loadingViews.map{ $0.removeFromSuperview()}
    }
    
}





