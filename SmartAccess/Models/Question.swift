//
//  QuestionsModel.swift
//  SmartAccess
//
//  Created by Vamshirkishna on 16/04/25.
//

struct Question {
    let questionName: String
    var answers: [AnswerOption]
}

struct AnswerOption{
    var answer:String
    var isSelected:Bool
}

func parseQuestions(from json: [String: Any]) -> [Question] {
    var questions: [Question] = []
    
    for (key, value) in json {
           if let answerStrings = value as? [String] {
               let answerOptions = answerStrings.map { AnswerOption(answer: $0, isSelected: false) }
               let question = Question(questionName: key, answers: answerOptions)
               questions.append(question)
           }
       }
    
    return questions
}
