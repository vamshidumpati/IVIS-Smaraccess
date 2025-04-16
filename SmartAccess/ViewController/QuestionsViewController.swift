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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitBtn.layer.cornerRadius = 5
        questionsTableView.register(UINib(nibName: "QuestionsTableViewCell", bundle: nil), forCellReuseIdentifier: "QuestionsTableViewCell")
        self.navigationItem.hidesBackButton = true
    }
}

extension QuestionsViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionsTableViewCell") as? QuestionsTableViewCell
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }
}
