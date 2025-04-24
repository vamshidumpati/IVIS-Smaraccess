//
//  AccountViewController.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 02/04/25.
//

import UIKit
import SVProgressHUD

class AccountViewController: UIViewController {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var accountView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var resendBtn: UIButton!
    
    var MFAFlag:Bool = false
    var userCredentials:[String:Any]?
    var selectedTag:Int?
    var mfaResponse:[String:Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoLabel.isHidden = true
        resendBtn.isHidden = true
        self.navigationItem.hidesBackButton = true
        if MFAFlag{
            sendMFAAuthentication()
        } else {
            setupUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !MFAFlag{
            accountTextField.text = "IIFL"
        }
    }
    
    func sendMFAAuthentication(){
        SVProgressHUD.show()
        if var credentials = userCredentials{
            credentials["twoFactorMethod"] = selectedTag == 101 ? "email" : "sms"
            NetworkManager.verifyMFAViaEmail(params: credentials) { data, error in
                SVProgressHUD.dismiss()
                if error == ""{
                    self.mfaResponse = data?["results"] as? [String:Any] ?? [:]
                    self.setupUI()
                } else {
                    self.displayAlert(title: "Error", message: error.description)
                }
            }
        }
    }
    
    func setupUI(){
        let placeholderColor = UIColor.white
        var placeholderText = ""
        if MFAFlag{
            let emailOrSMS = self.selectedTag == 101 ? mfaResponse?["email"] as? String ?? "" : mfaResponse?["mobilePhone"] as? String ?? ""
            infoLabel.isHidden = false
            resendBtn.isHidden = false
            placeholderText = "Enter Passcode"
            infoLabel.text = "MFA passcode has been sent to \(emailOrSMS). Please enter passcode to login."
            self.displayAlert(title: "Success", message: mfaResponse?["message"] as? String ?? "")
        } else {
            resendBtn.isHidden = true
            infoLabel.isHidden = true
            placeholderText = "Enter Account ID"
        }
        accountTextField.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        submitBtn.layer.cornerRadius = 18
        accountTextField.textColor = .white
    }
    
    override func viewDidLayoutSubviews() {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: accountView.frame.height - 1, width: accountView.frame.width, height: 0.7)
        bottomBorder.backgroundColor = UIColor.white.cgColor // Change color as needed
        accountView.layer.sublayers?.removeAll(where: { $0.backgroundColor == bottomBorder.backgroundColor })
        accountView.layer.addSublayer(bottomBorder)
    }
    
    @IBAction func onTapLoginAccount(_ sender: Any) {
        SVProgressHUD.show()
        let message = MFAFlag ? "Enter OTP" : "Please enter valid account id"
        if accountTextField.text?.count == 0 {
            self.displayAlert(title: "Sorry", message: message)
        } else {
            if MFAFlag{
                
            } else {
                NetworkManager.getAcccountDetails(accountNumber: accountTextField.text ?? "") { result, error in
                    SVProgressHUD.dismiss()
                    if(error != nil){
                        self.submitBtn.setTitle("Retry", for: .normal)
                        self.displayAlert(title: "Message", message: error!)
                    } else {
                        DataStore.shared.accountId = self.accountTextField.text ?? ""
                        UserDefaults.standard.setValue(self.accountTextField.text ?? "", forKey: "accountID")
                        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
                        self.navigationController?.pushViewController(loginVC!, animated: true)
                    }
                }
            }
        }
    }
    
    @IBAction func onTapResendAction(_ sender: Any) {
        
    }
    
}
