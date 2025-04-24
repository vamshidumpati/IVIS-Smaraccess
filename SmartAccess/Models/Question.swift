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

struct AnswerOption {
    var answer: String
    var isSelected: Bool
}

func parseQuestions(from json: [String: Any]) -> [Question] {
    var questions: [Question] = []
    
    // First check if we have the "results" dictionary
    guard let resultsDict = json["results"] as? [String: Any] else {
        print("No 'results' found in response")
        return []
    }
    
    // Iterate through each question category in results
    for (questionCategory, answerValues) in resultsDict {
        // Skip empty arrays
        guard let answersArray = answerValues as? [String], !answersArray.isEmpty else {
            continue
        }
        
        let answerOptions = answersArray.map { AnswerOption(answer: $0, isSelected: false) }
        let question = Question(questionName: questionCategory, answers: answerOptions)
        questions.append(question)
    }
    
    return questions
}
