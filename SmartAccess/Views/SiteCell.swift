//
//  SiteCell.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 07/04/25.
//

import Foundation
import UIKit

class SiteCell: UITableViewCell {

    @IBOutlet weak var borderView:UIView!
    @IBOutlet weak var siteName:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
