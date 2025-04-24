//
//  OTPViewController.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 21/04/25.
//

import UIKit
import SVProgressHUD

class OTPViewController: UIViewController {
    @IBOutlet weak var OTPTextField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var resendBtn: UIButton!
    
    var timer: Timer?
    var remainingSeconds = 30
    
    var isVaultVerified:((_ isVerifeid:Bool, _ error:String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startOTPTimer()
        sendOTP()
    }

    func setupUI(){
        setBottomBorder(for: OTPTextField)
        submitBtn.layer.cornerRadius = 10
        resendBtn.isEnabled = false
    }
    
    func sendOTP(){
        SVProgressHUD.show()
        NetworkManager.sendOTP { data, error in
            SVProgressHUD.dismiss()
            if error == ""{
                
            } else {
                self.displayAlert(title: "Error", message: error)
            }
            
        }
    }

    func setBottomBorder(for textField: UITextField, color: UIColor = .lightGray, height: CGFloat = 1.0) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: textField.frame.height - height, width: textField.frame.width, height: height)
        border.backgroundColor = color.cgColor
        textField.borderStyle = .none
        textField.layer.addSublayer(border)
    }

    func startOTPTimer() {
        remainingSeconds = 30
        resendBtn.isEnabled = false
        resendBtn.setTitle("Resend in 30 sec", for: .normal)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    @objc func updateTimer() {
        remainingSeconds -= 1
        if remainingSeconds > 0 {
            resendBtn.setTitle("Resend in \(remainingSeconds) sec", for: .normal)
        } else {
            timer?.invalidate()
            timer = nil
            resendBtn.setTitle("Resend OTP", for: .normal)
            resendBtn.isEnabled = true
        }
    }

    @IBAction func onTapSubmitOTP(_ sender: Any) {
        guard let otp = OTPTextField.text?.trimmingCharacters(in: .whitespaces), !otp.isEmpty else {
            self.displayAlert(title: "Invalid OTP", message: "Please enter OTP")
            return
        }

        let params: [String: Any] = [
            "empId": DataStore.shared.userInfo?.employeeId ?? "",
            "deviceId": DataStore.shared.vaultData?.ivisVault?.unit?.ivisunitId ?? "",
            "accessCode": DataStore.shared.userInfo?.accessCode ?? "",
            "access_type": DataStore.shared.vaultData?.ivisVaultConfiguration?.authenticationType ?? "",
            "user_type": DataStore.shared.vaultData?.userType ?? "",
            "otp": otp
        ]

        NetworkManager.validateOTP(params: params) { data, error in
            let isValid = (data?["otpStatus"] as? Bool) ?? false
            let errorMessage = error.isEmpty ? data?["remarks"] as? String ?? "" : error.description

            self.dismiss(animated: true) {
                self.isVaultVerified?(isValid, errorMessage)
            }
        }
    }


    @IBAction func onTapResendOTP(_ sender: Any) {
        sendOTP()
        startOTPTimer()
    }
}

