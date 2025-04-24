//
//  VaultCollectionViewCell.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 08/04/25.
//

import UIKit

class VaultCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var checkBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkBtn.isUserInteractionEnabled = false
    }
    
    func configureData(name:String){
        if name == "Packet Counting" || name == "Others"{
            itemImage.image = UIImage(named: "others")
        } else {
            itemImage.image = UIImage(named: name.lowercased())
        }
        itemName.text = name
    }
    
    @IBAction func onTapCheckMarkBtn(_ sender: Any) {
    }
    
    func setSelected(_ selected: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.checkBtn.tintColor = selected ? UIColor.green : UIColor(hex: "#1692DF")
            self.checkBtn.transform = selected ? CGAffineTransform(scaleX: 1.1, y: 1.1) : .identity
        }
    }
    
}
