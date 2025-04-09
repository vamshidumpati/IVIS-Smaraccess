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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(name: String, imageStr:String) {
        profileImage.image = profileImage.tag == 0 ? UIImage(named: imageStr) : UIImage(systemName:imageStr)
        profileImage.tintColor = UIColor.black
        profileName.text = name
    }
}
