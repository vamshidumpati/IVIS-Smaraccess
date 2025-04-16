//
//  QuestionsModel.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 16/04/25.
//

struct Question {
    let questionName: String
    let answers: [String]
}

func parseQuestions(from json: [String: Any]) -> [Question] {
    var questions: [Question] = []
    
    for (key, value) in json {
        if let answers = value as? [String] {
            let question = Question(questionName: key, answers: answers)
            questions.append(question)
        }
    }
    
    return questions
}
