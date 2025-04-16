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
    @IBOutlet weak var questionLbl: UILabel!
    
    var selectedTag:Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    
    var selectedIndexAndAnswer: ((_ index: Int?, _ answerIndex: Int?) -> Void)?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureQuestions(data:Question, tag:Int){
        let questionName = data.questionName
        selectedTag = tag
        let question =  questionName == "accessCodes" ? "Access code" : questionName == "datesOfBirth" ? "Date of birth" : questionName == "datesOfJoining" ? "Date of joining" : ""
        questionLbl.text = "Q. \(tag))" + question + "?"
        if !data.answers.isEmpty{
            firstBtn.tag = 1
            secondBtn.tag = 2
            thirdBtn.tag = 3
            firstBtn.setTitle(data.answers[0], for: .normal)
            secondBtn.setTitle(data.answers[1], for: .normal)
            thirdBtn.setTitle(data.answers[2], for: .normal)
        }
    }
    
    func setupUI(){
        questionLbl.font = UIFont(name: "Lato-Regular", size: 14.0)
        subView.backgroundColor = .white
        subView.layer.shadowColor = UIColor.black.cgColor
        subView.layer.shadowOpacity = 0.2
        self.contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
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
    
    @IBAction func onTapFirstAnswer(_ sender: Any) {
        selectedIndexAndAnswer?(selectedTag ?? -1, (sender as AnyObject).tag ?? -1)
    }
    
    @IBAction func onTapSecondAnswer(_ sender: Any) {
        selectedIndexAndAnswer?(selectedTag ?? -1, (sender as AnyObject).tag ?? -1)
    }
    
    @IBAction func onTapThirdAnswer(_ sender: Any) {
        selectedIndexAndAnswer?(selectedTag ?? -1, (sender as AnyObject).tag ?? -1)
    }
}
