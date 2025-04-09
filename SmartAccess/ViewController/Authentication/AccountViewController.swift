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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        accountTextField.text = "IIFL"
    }
    
    func setupUI(){
        let placeholderColor = UIColor.white
        let placeholderText = "Enter Account ID"
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
        if accountTextField.text?.count == 0 {
            self.displayAlert(title: "Sorry", message: "Please enter valid account id")
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
