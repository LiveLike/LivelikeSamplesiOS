//
//  File.swift
//  TF1Sample
//
//  Created by Work on 7/12/24.
//

import Foundation

protocol QuizViewModelListener {
    func quizDidExpire()
    func selectedChoiceDidChange(choiceID: String?)
    func answerSubmitted()
    func votePercentageDidChange(choiceID: String, votePercentage: Float)
}

protocol QuizViewModel {
    
    var tag: String { get set }
    var question: String { get set }
    var isQuizExpired: Bool { get }
    var isAnswerSubmitted: Bool { get }
    
    var choices: [QuizOptionViewModel] { get set }
    
    var selectedChoiceID: String? { get }
    
    func submitAnswer()
    
    var delegate: QuizViewModelListener? { get set }
    
    func registerImpression()
    
    func selectChoice(choiceID: String)
    
    func getVotePercentage(choiceID: String) -> Float
}

protocol QuizOptionViewModel: AnyObject {
    
    var id: String { get }
    var isCorrect: Bool { get }
    var imageURL: URL? { get }
    var text: String { get }
}

class FakeQuizViewModel: QuizViewModel {
    func getVotePercentage(choiceID: String) -> Float {
        return 0
    }
    
    var selectedChoiceID: String? {
        didSet {
            self.delegate?.selectedChoiceDidChange(choiceID: selectedChoiceID)
        }
    }
    
    init(tag: String, question: String, choices: [QuizOptionViewModel], canSubmitAnswer: Bool, isQuizExpired: Bool, userDidAnswer: Bool) {
        self.tag = tag
        self.question = question
        self.choices = choices
        self.isQuizExpired = isQuizExpired
        self.isAnswerSubmitted = userDidAnswer
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            choices.forEach { choice in
                self.delegate?.votePercentageDidChange(choiceID: choice.id, votePercentage: Float.random(in: 0...1))
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { _ in
            self.delegate?.quizDidExpire()
        }
    }
    
    var tag: String
    
    var question: String
    
    var choices: [QuizOptionViewModel]
    
    var isAnswerSubmitted: Bool
    
    var isQuizExpired: Bool {
        didSet {
            
        }
    }
    
    func submitAnswer() {
        self.delegate?.answerSubmitted()
        self.isAnswerSubmitted = true
    }
    
    var delegate: (any QuizViewModelListener)?
    
    func registerImpression() {
    }
    
    func selectChoice(choiceID: String) {
        self.selectedChoiceID = choiceID
    }
}

class LLQuizOptionViewModel: QuizOptionViewModel {
    
    init(id: String, isCorrect: Bool, imageURL: URL? = nil, text: String) {
        self.id = id
        self.isCorrect = isCorrect
        self.imageURL = imageURL
        self.text = text
    }
    
    let id: String
    let isCorrect: Bool
    let imageURL: URL?
    let text: String
}
