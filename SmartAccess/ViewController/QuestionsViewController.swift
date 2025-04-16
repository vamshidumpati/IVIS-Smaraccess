//
//  QuestionsViewController.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 15/04/25.
//

import UIKit

class QuestionsViewController: UIViewController {
    @IBOutlet weak var questionsTableView: UITableView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var submitBtnHeight: NSLayoutConstraint!
    
    var questions:[Question]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitBtn.layer.cornerRadius = 5
        questionsTableView.register(UINib(nibName: "QuestionsTableViewCell", bundle: nil), forCellReuseIdentifier: "QuestionsTableViewCell")
        self.navigationItem.hidesBackButton = true
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func onTapSubmitAnswers(_ sender: Any) {
    }
}

extension QuestionsViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionsTableViewCell") as? QuestionsTableViewCell
        if let questionsData = questions{
            cell?.configureQuestions(data: questionsData[indexPath.row], tag: indexPath.row + 1)
            cell?.selectedIndexAndAnswer = { [weak self] main, sub in
                print("main", main ?? -1)
                print("Sub", sub ?? -1)
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }
    
    
}
