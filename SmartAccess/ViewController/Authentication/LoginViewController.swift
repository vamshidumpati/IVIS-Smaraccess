//
//  LoginViewController.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 03/04/25.
//

import UIKit
import SVProgressHUD

class LoginViewController: UIViewController {
    @IBOutlet weak var userNameView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var fieldsStackView: UIStackView!
    @IBOutlet weak var switchAccount: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        usernameTF.text = "MLI1123"
        passwordTF.text = "Ivis@123"
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        fieldsStackView.layoutIfNeeded()
        addBottomBorder(to: userNameView)
        addBottomBorder(to: passwordView)
    }
    
    private func addBottomBorder(to view: UIView) {
        // Remove existing border layers to avoid duplicates
        view.layer.sublayers?.removeAll(where: { $0.name == "bottomBorder" })
        
        let bottomBorder = CALayer()
        bottomBorder.name = "bottomBorder"
        bottomBorder.frame = CGRect(x: 0, y: view.bounds.height - 1, width: view.bounds.width, height: 1) // Ensure full width
        bottomBorder.backgroundColor = UIColor.white.cgColor
        
        view.layer.addSublayer(bottomBorder)
    }
    
    func setupUI(){
        self.navigationItem.hidesBackButton = true
        
        //This code is for border on bottom of the view
        let userNamePlaceholderColor = UIColor.white
        let userNamePlaceHolderText = "User ID"
        usernameTF.attributedPlaceholder = NSAttributedString(
            string: userNamePlaceHolderText,
            attributes: [NSAttributedString.Key.foregroundColor: userNamePlaceholderColor]
        )
        
        let passWordPlaceholderColor = UIColor.white
        let passWordPlaceHolderText = "Password"
        passwordTF.attributedPlaceholder = NSAttributedString(
            string: passWordPlaceHolderText,
            attributes: [NSAttributedString.Key.foregroundColor: passWordPlaceholderColor]
        )
        
        submitBtn.layer.cornerRadius = 18
        switchAccount.layer.cornerRadius = 18
        usernameTF.textColor = .white
        passwordTF.textColor = .white
    }
    
    func isValidForm() -> Validation {
        var validation = Validation(valid: true, error: "")
        if(usernameTF.text?.count == 0) {
            validation = Validation(valid: false, error: "Please enter a username")
        }else if(passwordTF.text?.count == 0) {
            validation = Validation(valid: false, error: "Please enter a password")
        }
        
        return validation
    }
    
    @IBAction func onTapLogin(_ sender: Any) {
        let validation = isValidForm()
        if(validation.valid == false){
            self.displayAlert(title: "Message", message: validation.error)
            return
        }
        let userEmail = usernameTF.text ?? ""
        if userEmail.localizedStandardContains(".com"){
            if userEmail.isValidEmail(){
                self.loginUser()
            } else {
                self.displayAlert(title: "Message".localize, message: "Invalid email")
            }
        } else {
            self.loginUser()
        }
    }
    
    func loginUser(){
        SVProgressHUD.show()
        let accountId = DataStore.shared.accountId
        NetworkManager.getUserToken(username: usernameTF.text ?? "", password: passwordTF.text ?? "", accontId: accountId ?? "") { result, error in
            SVProgressHUD.dismiss()
            if error != nil{
                self.displayAlert(title: "Error", message: error)
            } else {
                if result?.errorMessage == "Login Authenticated"{
                    if let loggedInUserData = result?.results{
                        DataStore.shared.userAuth?.results = loggedInUserData
                        self.saveUserDataToUserDefaults(user: result!)
                        self.NavigateToDashboard()
                    }
                } else {
                    self.displayAlert(title: "Error", message: result?.errorMessage)
                }
            }
        }
    }
    
    func saveUserDataToUserDefaults(user: User) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user) {
            UserDefaults.standard.set(encoded, forKey: "UserAuthData")
        }
    }
    
    func NavigateToDashboard() {
        DispatchQueue.main.async {
            let tabBarController = MenuViewController()
            tabBarController.selectedIndex = 0
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate,
               let window = sceneDelegate.window {
                
                window.rootViewController = tabBarController
                window.makeKeyAndVisible()
                
                let transition = CATransition()
                transition.type = .fade
                transition.duration = 0.3
                window.layer.add(transition, forKey: kCATransition)
            }
        }
    }
    
    
    @IBAction func onTapSwitchAccount(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
