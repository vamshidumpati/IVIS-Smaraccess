//
//  QuestionsTableViewCell.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 15/04/25.
//

import UIKit

class QuestionsTableViewCell: UITableViewCell {
    @IBOutlet weak var questionsStackView: UIStackView!
    @IBOutlet weak var firstBtn: UIButton!
    @IBOutlet weak var secondBtn: UIButton!
    @IBOutlet weak var thirdBtn: UIButton!
    @IBOutlet weak var subView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupUI(){
        subView.backgroundColor = .white
        subView.layer.shadowColor = UIColor.black.cgColor
        subView.layer.shadowOpacity = 0.2
        self.contentView.layer.shadowOffset = CGSize(width: 0, height: -2)
        subView.layer.shadowRadius = 4
        subView.layer.masksToBounds = false
        subView.layer.cornerRadius = 5
        
        firstBtn.layer.cornerRadius = 14
        firstBtn.layer.borderWidth = 1
        firstBtn.layer.borderColor = UIColor(hex:"#3BC3F2").cgColor
        
        secondBtn.layer.cornerRadius = 14
        secondBtn.layer.borderWidth = 1
        secondBtn.layer.borderColor = UIColor(hex:"#3BC3F2").cgColor
        
        thirdBtn.layer.cornerRadius = 14
        thirdBtn.layer.borderWidth = 1
        thirdBtn.layer.borderColor = UIColor(hex: "#3BC3F2").cgColor
    }
}
