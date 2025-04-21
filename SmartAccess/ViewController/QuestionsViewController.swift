//
//  QuestionsViewController.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 15/04/25.
//

import UIKit
import SVProgressHUD

class QuestionsViewController: UIViewController {
    @IBOutlet weak var questionsTableView: UITableView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var submitBtnHeight: NSLayoutConstraint!
    
    var questions:[Question]?
    var answeredQuestions:[String:Any]?
    var selectedAnswers:[String:Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitBtn.layer.cornerRadius = 5
        questionsTableView.register(UINib(nibName: "QuestionsTableViewCell", bundle: nil), forCellReuseIdentifier: "QuestionsTableViewCell")
        self.navigationItem.hidesBackButton = true
        self.tabBarController?.tabBar.isHidden = false
        fetchChecklistQuestions()
    }
    
    //Comment it later
    func fetchChecklistQuestions(){
        SVProgressHUD.show()
        NetworkManager.getChecklistQuestions { data, error in
            SVProgressHUD.dismiss()
            if error == ""{
                self.questions = data ?? []
                self.questionsTableView.reloadData()
            } else {
                self.displayAlert(title: "Error", message: "Failed to fetch checklist questions")
            }
        }
    }
    
    func captureAnswer(questionIndex: Int, answerIndex: Int) {
        // Ensure we have a valid question
        guard var questionData = questions?[questionIndex] as? Question else { return }

        // Deselect all answers
        questionData.answers = questionData.answers.map { answer in
            var updatedAnswer = answer
            updatedAnswer.isSelected = false
            return updatedAnswer
        }

        // Select the tapped answer
        questionData.answers[answerIndex].isSelected = true

        // Save updated question back to the array
        questions?[questionIndex] = questionData

        // Initialize dictionaries if nil
        if answeredQuestions == nil {
            answeredQuestions = [:]
        }
        if selectedAnswers == nil {
            selectedAnswers = [:]
        }

        // Generate key based on questionName
        let key: String
        switch questionData.questionName {
        case "datesOfJoining": key = "dateOfJoining"
        case "accessCodes":    key = "accessCode"
        case "datesOfBirth":   key = "dateOfBirth"
        default:               key = ""
        }

        // Safely update answer only if key is not empty
        if !key.isEmpty {
            answeredQuestions?[key] = questionData.answers[answerIndex]
            selectedAnswers?[key] = questionData.answers[answerIndex].answer
        }

        // Reload the row
        let indexPath = IndexPath(row: questionIndex, section: 0)
        questionsTableView.reloadRows(at: [indexPath], with: .automatic)
    }

    
    @IBAction func onTapSubmitAnswers(_ sender: Any) {
        if questions?.count != answeredQuestions?.keys.count{
            self.displayAlert(title: "Error", message: "Please answer all the questions")
            return
        }
        SVProgressHUD.show()
        let valultID = DataStore.shared.vaultData?.ivisVault?.pkVaultId
        if let answeredData = selectedAnswers, let vaultid = valultID{
            NetworkManager.submitAnswers(params: answeredData, vaultId: vaultid) { response, error in
                SVProgressHUD.dismiss()
                if response["status"] as? Int ?? 0 == 400{
                    self.displayAlert(title: "Error", message: "Personal details validation failed.")
                } else if response["status"] as? Int ?? 0 == 200{
                    self.presentOPTViewController()
                }
            }
        }
    }
    
    func presentOPTViewController(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OTPViewController") as? OTPViewController
        vc?.modalPresentationStyle = .overFullScreen
        vc?.modalTransitionStyle = .crossDissolve
        self.present(vc!, animated: true)
    }
}

extension QuestionsViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionsTableViewCell") as? QuestionsTableViewCell
        if let questionsData = questions{
            cell?.configureQuestions(data: questionsData[indexPath.row], tag: indexPath.row)
            cell?.selectedIndexAndAnswer = { [weak self] main, sub in
                self?.captureAnswer(questionIndex: main ?? -1, answerIndex: sub ?? -1)
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }
}
