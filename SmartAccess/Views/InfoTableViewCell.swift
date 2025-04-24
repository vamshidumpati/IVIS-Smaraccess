//
//  InfoTableViewCell.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 08/04/25.
//

import UIKit

class InfoTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var leading: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(name: String, imageStr: String, deviceStatus: String) {
        // Set image
        if profileImage.tag == 0 {
            profileImage.image = UIImage(named: imageStr)?.withRenderingMode(.alwaysTemplate)
        } else {
            profileImage.image = UIImage(systemName: imageStr)?.withRenderingMode(.alwaysTemplate)
        }
        
        // Set tint color
        if !deviceStatus.isEmpty {
            profileImage.tintColor = (deviceStatus == "Online") ? UIColor(hex: "1692DF") : .gray
        } else {
            profileImage.tintColor = .black
        }
        // Set name
        profileName.text = name
    }
}
