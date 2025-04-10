//
//  ProfileDetailsTableViewCell.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 10/04/25.
//

import UIKit

class ProfileDetailsTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var phoneNumberLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        bindData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindData(){
        nameLbl.text = "Name : " + ( DataStore.shared.userAuth?.results.fullName.description ?? "-")
        emailLbl.text = "Email : " + ( DataStore.shared.userAuth?.results.email.description ?? "-")
        phoneNumberLbl.text = "Phone Number : " + ( DataStore.shared.userAuth?.results.mobilePhone.description ?? "")
        nameLbl.font = UIFont(name: "Lato-Medium", size: 16.0)
        emailLbl.font = UIFont(name: "Lato-Medium", size: 16.0)
        phoneNumberLbl.font = UIFont(name: "Lato-Medium", size: 16.0)
        statusLbl.font = UIFont(name: "Lato-Medium", size: 16.0)
    }
    
}
