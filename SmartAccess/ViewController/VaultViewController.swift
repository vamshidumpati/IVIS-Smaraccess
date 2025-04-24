//
//  VaultViewController.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 24/04/25.
//

import UIKit

class VaultViewController: UIViewController {
    @IBOutlet weak var vaultImage: UIImageView!
    @IBOutlet weak var deniedLable: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vaultImage.isHidden = true
        deniedLable.isHidden = true
        deniedLable.font = UIFont(name: "Lato-Medium", size: 14.0)
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.presentOPTViewController()
    }
    
    func presentOPTViewController(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OTPViewController") as? OTPViewController
        vc?.modalPresentationStyle = .overFullScreen
        vc?.isVaultVerified = { [weak self] (verified, error) in
            self?.deniedLable.isHidden = false
            if verified{
                self?.vaultImage.isHidden = false
                self?.deniedLable.text = "Vault access granted"
                self?.deniedLable.textColor = .green
            } else {
                self?.deniedLable.text = "Vault access denied"
                self?.deniedLable.textColor = .red
                self?.displayAlert(title: "Error", message: error)
            }
        }
        vc?.modalTransitionStyle = .crossDissolve
        self.present(vc!, animated: true)
    }
}
