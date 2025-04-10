//
//  UserProfileViewController.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 09/04/25.
//

import UIKit
import SVProgressHUD

class UserProfileViewController: UIViewController {
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var detailsStackView: UIStackView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var phoneNumberLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var captureBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.isHidden = true
        bottomView.isHidden = true
        fetchUserData()
    }
    
    func setupUI(){
        imageView.isHidden = false
        bottomView.isHidden = false
        nameLbl.text = "Name : " + ( DataStore.shared.userInfo?.firstName ?? "-") + " " + (DataStore.shared.userInfo?.lastName ?? "-")
        emailLbl.text = "Email : " + ( DataStore.shared.userInfo?.email ?? "-")
        phoneNumberLbl.text = "Phone Number : " + ( DataStore.shared.userInfo?.mobilePhone ?? "-")
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
        
        // For imageView
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        imageView.layer.shadowOpacity = 0.3
        imageView.layer.shadowRadius = 4
        imageView.layer.masksToBounds = false

        // For bottomView
        bottomView.layer.shadowColor = UIColor.black.cgColor
        bottomView.layer.shadowOffset = CGSize(width: 0, height: -2)  // Shadow on top
        bottomView.layer.shadowOpacity = 0.3
        bottomView.layer.shadowRadius = 4
        bottomView.layer.masksToBounds = false
        
        let profileStatus = DataStore.shared.userInfo?.userProfileRequest?.state ?? "-"
        statusLbl.text = "Status : " + ( profileStatus == "-" ? "No Profile" : profileStatus)

        
        if profileStatus == "Approved"{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.tabBarController?.selectedIndex = 0
            }
        }else{
            self.displayAlert(title: "Profile Status", message: "Your profile is not approved by admin.")
            self.tabBarController?.tabBar.isUserInteractionEnabled = false
        }
        captureBtn.isHidden = profileStatus != "Approved" ? false : true
        let isProfileApproved = DataStore.shared.userInfo?.userProfileRequest?.state == "Approved" ? true : false
        self.updateTabAppearance(isProfileActive: isProfileApproved)
    }
    
    func fetchUserData(){
        SVProgressHUD.show()
        let que = OperationQueue()
        let getUserImage = BlockOperation{
            NetworkManager.getUserProfileImage { profileImage,error in
                if let error = error{
                    print("Error")
                }
                DispatchQueue.main.async {
                    self.profileImageView.image = profileImage
                }
            }
        }
        let getUserProfile = BlockOperation{
            NetworkManager.getUserProfileInformation { error  in
                SVProgressHUD.dismiss()
                if error == ""{
                    self.setupUI()
                } else{
                    self.displayAlert(title: "Error", message: "Failed to fetch the user profile information")
                }
            }
        }
        getUserProfile.addDependency(getUserImage)
        que.addOperations([getUserImage,getUserProfile], waitUntilFinished: false)
    }
    
    func updateTabAppearance(isProfileActive: Bool) {
        DispatchQueue.main.async {
            let config = UIImage.SymbolConfiguration(paletteColors: [
                isProfileActive ? .systemGreen : .systemRed
            ])
            
            self.tabBarItem.image = UIImage(
                systemName: isProfileActive ? "person.fill.checkmark" : "person.fill.xmark",
                withConfiguration: config
            )
            
            self.tabBarItem.selectedImage = UIImage(
                systemName: isProfileActive ? "person.fill.checkmark" : "person.fill.xmark",
                withConfiguration: config
            )
            
            UIView.animate(withDuration: 0.3) {
                self.tabBarController?.tabBar.tintColor = isProfileActive ? .systemGreen : .systemRed
                self.tabBarController?.tabBar.layoutIfNeeded()
            }
        }
    }
}
