//
//  UserProfileViewController.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 09/04/25.
//

import UIKit

class UserProfileViewController: UIViewController {
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var detailsStackView: UIStackView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var phoneNumberLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    func setupUI(){
        nameLbl.text = "Name : " + ( DataStore.shared.userAuth?.results.fullName.description ?? "-")
        emailLbl.text = "Email : " + ( DataStore.shared.userAuth?.results.email.description ?? "-")
        phoneNumberLbl.text = "Phone Number : " + ( DataStore.shared.userAuth?.results.mobilePhone.description ?? "")
        nameLbl.font = UIFont(name: "Lato-Medium", size: 16.0)
        emailLbl.font = UIFont(name: "Lato-Medium", size: 16.0)
        phoneNumberLbl.font = UIFont(name: "Lato-Medium", size: 16.0)
        statusLbl.font = UIFont(name: "Lato-Medium", size: 16.0)

        imageView.layer.cornerRadius = 20
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowRadius = 5
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        bottomView.layer.cornerRadius = 20
        bottomView.layer.shadowColor = UIColor.black.cgColor
        bottomView.layer.shadowRadius = 5
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
