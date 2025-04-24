//
//  MFAAuthenitcaionViewController.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 22/04/25.
//

import UIKit

class MFAAuthenitcaionViewController: UIViewController {
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var emailBtn: UIButton!
    @IBOutlet weak var emailImage: UIImageView!
    @IBOutlet weak var smsBtn: UIButton!
    @IBOutlet weak var smsImage: UIImageView!
    
    var response:String?
    var loginDetails:[String:Any]?
    var twoFactorId:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    func setupUI(){
        infoLabel.font = UIFont(name: "Lato-Regular", size: 14.0)
        emailImage.isUserInteractionEnabled = false
        smsImage.isUserInteractionEnabled = false
        
        emailBtn.titleLabel?.font = UIFont(name: "Lato-Medium", size: 14.0)
        smsBtn.titleLabel?.font = UIFont(name: "Lato-Medium", size: 14.0)
        
        emailBtn.layer.cornerRadius = 20
        smsBtn.layer.cornerRadius = 20
        self.navigationItem.hidesBackButton = true
        if let errorResponse = response{
            let itemsInString = convertStringToArray(data: errorResponse)
            emailBtn.isHidden = itemsInString.contains("email") ? false : true
            smsBtn.isHidden = itemsInString.contains("sms") ? false : true
        }
    }
    
    func convertStringToArray(data:String) -> [String]{
        let myString = data
        let cleanedString = myString.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
        let items = cleanedString.components(separatedBy: ", ").map { $0.trimmingCharacters(in: .whitespaces) }
        return items
    }
    
    @IBAction func onTapOfEmail(_ sender: Any) {
        self.navigateToOTPScreen(tag: 101)
    }
    
    @IBAction func onTapOfSMS(_ sender: Any) {
        self.navigateToOTPScreen(tag: 102)
    }

    
    func navigateToOTPScreen(tag:Int){
        let accountVC = self.storyboard?.instantiateViewController(withIdentifier: "AccountViewController") as? AccountViewController
        accountVC?.selectedTag = tag
        accountVC?.userCredentials = loginDetails
        accountVC?.MFAFlag = true
        self.navigationController?.pushViewController(accountVC!, animated: true)
    }

}
